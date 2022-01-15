    (   env:DHALL_CI
      ? https://raw.githubusercontent.com/timbertson/dhall-ci/1d73fedfcc122ed19163462cecb57dec2c766b29/package.dhall
          sha256:12954ab5215e3b11c3cb273d5953ceca7e96604d2612e0db2d1f2ffc9b1254e2
    )
/\  { SelfUpdate =
          (env:DHALL_CI_META).SelfUpdate
        ? https://raw.githubusercontent.com/timbertson/dhall-ci/1d73fedfcc122ed19163462cecb57dec2c766b29/Meta/SelfUpdate.dhall
            sha256:7058dec3a5e84800bfcec785f7b2c670e8c1d593e7a92143ccae5dcde96eb42f
    }
