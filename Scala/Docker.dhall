let Docker = ../dependencies/Docker.dhall

let Step = Docker.Step

let Image = Docker.Image

let Prelude = ../dependencies/Prelude.dhall

let map = Prelude.List.map

let Options =
      { cmd : List Text
      , workdir : Text
      , sbt : Image.Type
      , initRequires : List Text
      , initTargets : List Text
      , updateRequires : List Text
      , updateTargets : List Text
      , buildRequires : List Text
      , buildTargets : List Text
      , builderSetup : List Step.Type
      }

let default =
      { workdir = "/app"
      , cmd = [] : List Text
      , sbt = Docker.Image::{ name = "mozilla/sbt " }
      , initRequires = [ "project" ]
      , initTargets = [ "about" ]
      , updateRequires = [ "build.sbt" ]
      , updateTargets = [ "update" ]
      , buildRequires = [] : List Text
      , buildTargets = [] : List Text
      , builderSetup = [] : List Step.Type
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
              [ [ Step.fromAs options.sbt target ]
              , [ Step.workdir options.workdir ]
              , options.builderSetup
              , runSbt options options.initRequires options.initTargets
              , runSbt options options.updateRequires options.updateTargets
              , runSbt options options.buildRequires options.buildTargets
              ]

let steps = \(options : Options) -> builderSteps options "builder"

in  { Type = Options, default, steps, builderSteps }
