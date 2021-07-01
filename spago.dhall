{ name = "my-project"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "effect"
  , "foldable-traversable"
  , "httpure"
  , "maybe"
  , "node-buffer"
  , "node-fs-aff"
  , "optparse"
  , "partial"
  , "prelude"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "purs/**/*.purs" ]
}
