{ name =
    "zilch-playground"
, dependencies =
    [ "aff"
    , "ansi"
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
    , "posix-types"
    , "prelude"
    , "psci-support"
    , "transformers"
    , "tuples"
    , "uuid"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "purs/**/*.purs" ]
}
