{ name =
    "my-project"
, dependencies =
    [ "aff"
    , "arrays"
    , "console"
    , "effect"
    , "foldable-traversable"
    , "httpure"
    , "node-buffer"
    , "node-fs-aff"
    , "optparse"
    , "prelude"
    , "psci-support"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "src/**/*.purs" ]
}
