{ name =
    "zilch-playground"
, dependencies =
    [ "aff"
    , "argonaut"
    , "argonaut-codecs"
    , "arrays"
    , "console"
    , "datetime"
    , "effect"
    , "either"
    , "foldable-traversable"
    , "httpure"
    , "maybe"
    , "node-buffer"
    , "node-child-process"
    , "node-fs-aff"
    , "now"
    , "optparse"
    , "partial"
    , "pathy"
    , "posix-types"
    , "prelude"
    , "psci-support"
    , "transformers"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "purs/**/*.purs" ]
}
