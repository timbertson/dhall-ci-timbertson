{-|
# Note: copied from dhall-ci/Meta, merge at some point?
-}
let CI = ../dependencies/CI.dhall

let Docker = ../dependencies/Docker.dhall

let Render = ../dependencies/Render.dhall

let Git = (../dependencies/Git.dhall).Workflow

let Bash = CI.Bash

let Workflow = CI.Workflow

let dhallVersion = "1.37"

let dhallImage =
      Docker.Image::{
      , name = "${Docker.Registry.githubPackages}/timbertson/dhall-ci/dhall"
      , tag = Some dhallVersion
      }

let Files =
      { Type =
          { ciScript : Bash.Type
          , ciSteps : List Workflow.Step.Type
          , repo : Text
          , packages : List Text
          , bumpFiles : List Text
          }
      , default =
        { ciSteps = [] : List Workflow.Step.Type
        , packages = [ "dhall/files.dhall" ]
        , bumpFiles = [ "dhall/dependencies/*.dhall" ]
        }
      }

let appImage =
      \(repo : Text) ->
        Docker.Image::{
        , name = "${Docker.Registry.githubPackages}/timbertson/${repo}/app"
        }

let dhallRenderAndLint = [ "./dhall/render", "./dhall/fix --lint dhall" ]

let ci =
      \(opts : Files.Type) ->
        let appImage = appImage opts.repo

        let commitImage = Docker.Workflow.commitImage appImage

        in  Workflow::{
            , name = "CI"
            , on = Workflow.On.pullRequestOrMain
            , jobs = toMap
                { build = Workflow.Job::{
                  , runs-on = CI.Workflow.ubuntu
                  , steps =
                        [ Git.checkout Git.Checkout::{=}
                        , Docker.Workflow.loginToGithub
                        ]
                      # Docker.Workflow.Project.steps
                          Docker.Workflow.Project::{ image = appImage }
                      # opts.ciSteps
                      # [     Workflow.Step.bash
                                ( Docker.run
                                    Docker.Run::{ image = commitImage }
                                    opts.ciScript
                                )
                          //  { name = Some "Check generated files" }
                        ]
                  }
                }
            }

let selfUpdate =
      \(opts : Files.Type) ->
        CI.SelfUpdate.workflow
          CI.SelfUpdate::{ dhallImage, update = dhallRenderAndLint }

let files =
      \(opts : Files.Type) ->
            Render.SelfInstall.files Render.SelfInstall::{=}
        //  { `.github/workflows/ci.yml` = (Render.YAMLFile Workflow.Type)::{
              , install = Render.Install.Write
              , contents = ci opts
              }
            , `.github/workflows/dhall-update.yml` = ( Render.YAMLFile
                                                         Workflow.Type
                                                     )::{
              , install = Render.Install.Write
              , contents = selfUpdate opts
              }
            , `.gitattributes` = Render.TextFile::{
              , install = Render.Install.Write
              , contents =
                  ''
                  generated/** linguist-generated
                  .github/workflows/ci.yml linguist-generated
                  .github/workflows/dhall-update.yml linguist-generated
                  README.md linguist-generated
                  ''
              }
            , `.tool-versions` = Render.TextFile::{
              , contents =
                  ''
                  dhall ${dhallVersion}
                  ''
              }
            , `.ignore` = Render.TextFile::{
              , contents =
                  ''
                  generated/
                  .github/workflows
                  ''
              }
            }

in  { files, Files, dhallVersion }
