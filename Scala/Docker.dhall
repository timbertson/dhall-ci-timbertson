let Docker = ../dependencies/Docker.dhall

let Prelude = ../dependencies/Prelude.dhall

let Step = Docker.Step

let map = Prelude.List.map

let Options =
      { cmd : List Text
      , workdir : Text
      , initRequires : List Text
      , initTargets : List Text
      , updateRequires : List Text
      , updateTargets : List Text
      , buildRequires : List Text
      , buildTargets : List Text
      , builderSetup : List Step.Type
      , scalaVersion : Text
      }

let jdkVersion = "11.0.13"

let sbtVersion = "1.5.7"

let defaultScalaVersion = "2.13.7"

let default =
      { workdir = "/app"
      , cmd = [] : List Text
      , initRequires = [ "project" ]
      , initTargets = [ "about" ]
      , updateRequires = [ "build.sbt" ]
      , updateTargets = [ "update" ]
      , buildRequires = [] : List Text
      , buildTargets = [] : List Text
      , builderSetup = [] : List Step.Type
      , scalaVersion = defaultScalaVersion
      }

let sbt =
      \(opts : Options) ->
        Docker.Image::{
        , name = "hseeberger/scala-sbt"
        , tag = Some "${jdkVersion}_${sbtVersion}_${opts.scalaVersion}"
        }

let copy = \(path : Text) -> Step.copy path path

let builderSteps =
      \(options : Options) ->
      \(target : Text) ->
        let runSbt =
              \(options : Options) ->
              \(copyFiles : List Text) ->
              \(targets : List Text) ->
                  map Text Step.Type copy copyFiles
                # ( if    Prelude.List.null Text targets
                    then  [] : List Step.Type
                    else  [ Step.run ([ "sbt" ] # targets) ]
                  )

        in  Prelude.List.concat
              Step.Type
              [ [ Step.fromAs (sbt options) target ]
              , [ Step.workdir options.workdir ]
              , options.builderSetup
              , runSbt options options.initRequires options.initTargets
              , runSbt options options.updateRequires options.updateTargets
              , runSbt options options.buildRequires options.buildTargets
              ]

let steps = \(options : Options) -> builderSteps options "builder"

in  { Type = Options, default, steps, builderSteps, jdkVersion, sbtVersion }
