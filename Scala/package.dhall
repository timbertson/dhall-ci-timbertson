let Render = ../dependencies/Render.dhall

let Docker = ../dependencies/Docker.dhall

let ScalaDocker = ./Docker.dhall

let Workflow = ../Workflow/package.dhall

let ScalaFile =
    -- install with `write` so that we don't have to copy
    -- generated/ files in during the docker build
      { Type = Render.TextFile.Type
      , default =
              Render.TextFile.default
          //  { headerFormat = Render.Header.doubleSlash
              , install = Render.Install.Write
              }
      }

let Files =
      let dockerDefault =
          -- release.sbt sets scalaVersion, which affects dependency resolution
                ScalaDocker.default
            //  { updateRequires =
                    ScalaDocker.default.updateRequires # [ "release.sbt" ]
                }

      in  { Type =
              { repo : Text
              , docker : ScalaDocker.Type
              , scalaVersion : Text
              , strictPluginOverride : Optional Text
              }
          , default =
            { strictPluginOverride = None Text
            , docker = dockerDefault
            , scalaVersion = dockerDefault.scalaVersion
            }
          }

let publicLibraryFiles =
      \(opts : Files.Type) ->
        { `project/sonatype.sbt` = ScalaFile::{
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
        , `release.sbt` = ScalaFile::{
          , contents =
              ''
              ThisBuild / scalaVersion := "${opts.scalaVersion}"
              ThisBuild / organization := "net.gfxmonk"
              ThisBuild / homepage := Some(url(s"https://github.com/timbertson/${opts.repo}"))
              ThisBuild / scmInfo := Some(
                ScmInfo(
                  url("https://github.com/timbertson/${opts.repo}"),
                  s"scm:git@github.com:timbertson/${opts.repo}.git"
                )
              )
              ${./content/release.sbt as Text}
              ''
          }
        }

let strictFiles =
      \(opts : Files.Type) ->
        { `project/strict.sbt` = ScalaFile::{
          , contents =
              let strictLine =
                    merge
                      { None =
                          ''
                          addSbtPlugin("net.gfxmonk" % "sbt-strict-scope" % "2.1.0")
                          ''
                      , Some = \(t : Text) -> t
                      }
                      opts.strictPluginOverride

              in  ''
                  addSbtPlugin("io.github.davidgregory084" % "sbt-tpolecat" % "0.1.20")
                  ${strictLine}
                  ''
          }
        }

let files =
      \(opts : Files.Type) ->
            publicLibraryFiles opts
        /\  strictFiles opts
        /\  Workflow.files
              Workflow.Files::{
              , repo = opts.repo
              , ciScript = [ "sbt 'strict compile' test" ]
              }
        /\  { `project/build.properties` = ScalaFile::{
              , contents =
                  ''
                  sbt.version=${ScalaDocker.sbtVersion}
                  ''
              }
            , `.dockerignore` = Render.TextFile::{
              , contents =
                  ''
                  .git
                  target/
                  ''
              }
            , Dockerfile = Render.TextFile::{
              , contents =
                  Docker.render
                    ( ScalaDocker.steps
                        (opts.docker with scalaVersion = opts.scalaVersion)
                    )
              }
            }

in  { Files, files, ScalaFile, Docker = ScalaDocker }
