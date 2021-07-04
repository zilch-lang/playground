module CLI where

import Data.Foldable (fold)
import Effect (Effect)
import Options.Applicative ( Parser, option, int, long, short, metavar, help
                           , showDefault, value, execParser, info, helper
                           , fullDesc, progDesc, (<**>) )
import Prelude

type CLI = { port :: Int }

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

  in { port }

-- | A simple `main` wrapper to automatically parse the command-line.
cliMain :: forall b. (CLI -> Effect b) -> Effect b
cliMain main' = main' =<< execParser opts
  where
    opts = info (cli <**> helper) $ fold
             [ fullDesc, progDesc "Run the server for the Zilch playground" ]
