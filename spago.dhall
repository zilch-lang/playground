{ name =
    "zilch-playground"
, dependencies =
    [ "aff"
    , "argonaut"
    , "argonaut-codecs"
    , "arrays"
    , "console"
    , "effect"
    , "either"
    , "foldable-traversable"
    , "httpure"
    , "maybe"
    , "node-buffer"
    , "node-child-process"
    , "node-fs-aff"
    , "optparse"
    , "partial"
    , "pathy"
    , "prelude"
    , "psci-support"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "purs/**/*.purs" ]
}
