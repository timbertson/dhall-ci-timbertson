let Render = ../dependencies/Render.dhall

let Docker = ../dependencies/Docker.dhall

let ScalaDocker = ./Docker.dhall

let ScalaFile =
      { Type = Render.TextFile.Type
      , default =
              Render.TextFile.default
          //  { headerFormat = Render.Header.doubleSlash }
      }

let publicLibraryFiles =
      { `project/publish.sbt` = ScalaFile::{
        , contents =
            ''
            addSbtPlugin("com.jsuereth" % "sbt-pgp" % "2.0.1")
            addSbtPlugin("org.xerial.sbt" % "sbt-sonatype" % "3.9.7")
            ''
        }
      , `project/src/main/scala/PublishSettings.scala` = ScalaFile::{
        , contents = ./content/project/PublishSettings.scala as Text
        }
      , `release.sh` = Render.Executable::{
        , contents =
            ''
            #!/usr/bin/env bash
            sbt publishSigned sonatypeBundleRelease
            ''
        }
      , `version.sbt` = ScalaFile::{
        , contents =
            ''
            version := IO.read(new File("VERSION"))
            ''
        }
      }

let strictFiles =
      { `project/strict.sbt` = ScalaFile::{
        , contents =
            ''
            addSbtPlugin("io.github.davidgregory084" % "sbt-tpolecat" % "0.1.20")
            addSbtPlugin("net.gfxmonk" % "sbt-strict-scope" % "2.1.0")
            ''
        }
      }

let Workflow = ../Workflow/package.dhall

let Files =
      { Type = { repo : Text, docker : ScalaDocker.Type }
      , default.docker = ScalaDocker.default
      }

let files =
      \(opts : Files.Type) ->
            publicLibraryFiles
        /\  strictFiles
        /\  Workflow.files
              Workflow.Files::{
              , repo = opts.repo
              , ciScript = [ "sbt 'strict compile' test" ]
              }
        /\  { Dockerfile = Render.TextFile::{
              , contents = Docker.render (ScalaDocker.steps ScalaDocker::{=})
              }
            }

in  { Files, files, ScalaFile, Docker = ScalaDocker }
