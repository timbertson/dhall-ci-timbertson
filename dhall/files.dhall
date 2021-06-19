let Meta = ./Meta.dhall

in  { files =
        Meta.files
          Meta.Files::{
          , bumpFiles =
              Meta.Files.default.bumpFiles # [ "dependencies/Render.dhall" ]
          , packages = [ "dhall/files.dhall", "Scala/package.dhall" ]
          , readme = Meta.Readme::{
            , repo = "dhall-ci-timbertson"
            , componentDesc = Some "my own personal utilities"
            , parts =
              [ ''
                You shouldn't use this repository directly (I'll change things on a whim),
                but it serves as a useful example of a high level `dhall-ci` repository.
                Rather than providing many low-level building blocks, it provides
                high level reusable data and functions for different repository types.
                ''
              ]
            }
          }
    }
