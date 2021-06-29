{ name = "my-project"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "foldable-traversable"
  , "httpure"
  , "optparse"
  , "prelude"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
