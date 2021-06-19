let Render = ../dependencies/Render.dhall

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
            addSbtPlugin("com.jsuereth" % "sbt-pgp" % "1.1.0-M1")
            addSbtPlugin("org.xerial.sbt" % "sbt-sonatype" % "3.9.7")
            ''
        }
      , `project/src/main/scala/PublishSettings.scala` = ScalaFile::{
        , contents = ./content/project/PublishSettings.scala as Text
        }
      , `version.sbt` = ScalaFile::{
        , contents =
            ''
            version := sys.env.getOrElse("VERSION", "0-SNAPSHOT")
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

in  { publicLibraryFiles, strictFiles, ScalaFile }
