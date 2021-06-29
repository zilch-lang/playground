{ name =
    "my-project"
, dependencies =
    [ "console", "effect", "prelude", "psci-support", "optparse" ]
, packages =
    ./packages.dhall
, sources =
    [ "src/**/*.purs" ]
}
