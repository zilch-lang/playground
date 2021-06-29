module Main where

import Prelude (($), show, (=<<), map)

import Effect.Console as Console

import Options.Applicative ( Parser, option, int, long, short, metavar, help
                           , showDefault, value, execParser, info, helper
                           , fullDesc, progDesc, (<**>) )

import Data.Foldable (fold)
import Data.Semigroup ((<>))

import HTTPure as HTTPure



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

-- | Main function, running the command-line arguments parser
--   and the server.
main :: HTTPure.ServerM
main = runServer =<< execParser opts
  where
    opts = info (cli <**> helper) $ fold
             [ fullDesc, progDesc "Run the server for the Zilch playground" ]

-- | Runs the server on the given port.
runServer :: CLI -> HTTPure.ServerM
runServer { port } = HTTPure.serve port serverHandler do
  Console.log $ "Server running on port " <> show port <> "."

-- | Handles requests coming to the server.
serverHandler :: HTTPure.Request -> HTTPure.ResponseM
serverHandler { method: HTTPure.Get, path: [] } = do
  HTTPure.ok "Hello, world!"
serverHandler _ = HTTPure.notFound
