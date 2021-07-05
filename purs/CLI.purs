module CLI where

import Data.Foldable (fold)
import Effect (Effect)
import Options.Applicative ( Parser, option, int, long, short, metavar, help
                           , showDefault, value, execParser, info, helper
                           , fullDesc, progDesc, (<**>), strOption )
import Prelude

type CLI =
  { port :: Int
  , gzcExe :: String
  , gccExe :: String
  , outDir :: String
  }

-- | Parses the command-line arguments:
--
--   * @--port[=8080]@: indicates on which port the server should run
cli :: Parser CLI
cli = ado
  port <- option int $ fold
          [ long "port"
          , short 'p'
          , metavar "PORT"
          , help "Sets the port for the server"
          , showDefault
          , value 8080
          ]
  gzcExe <- strOption $ fold
            [ long "with-gzc"
            , metavar "GZC"
            , help "Uses a custom `gzc` executable"
            , showDefault
            , value "gzc"
            ]
  gccExe <- strOption $ fold
            [ long "with-gcc"
            , metavar "GCC"
            , help "Uses a custom `gcc` executable"
            , showDefault
            , value "gcc"
            ]
  outDir <- strOption $ fold
            [ long "out"
            , short 'o'
            , metavar "OUTPUT-DIR"
            , help "Sets the output directory, used to store temporary source files"
            , showDefault
            , value "./out"
            ]

  in { port, gzcExe, gccExe, outDir }

-- | A simple `main` wrapper to automatically parse the command-line.
cliMain :: forall b. (CLI -> Effect b) -> Effect b
cliMain main' = main' =<< execParser opts
  where
    opts = info (cli <**> helper) $ fold
             [ fullDesc, progDesc "Run the server for the Zilch playground" ]
