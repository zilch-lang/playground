module Main where

import Prelude

import Effect.Console as Console

import Options.Applicative ( Parser, option, int, long, short, metavar, help
                           , showDefault, value, execParser, info, helper
                           , fullDesc, progDesc, (<**>) )

import Data.Foldable (fold, intercalate)
import Data.Semigroup ((<>))

import HTTPure ((!@))
import HTTPure as HTTPure

import Node.FS.Aff as FS

import Node.Encoding as Encoding

import Data.Array (null, (:))



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
serverHandler { method: HTTPure.Get, path }
  | null path            = FS.readTextFile Encoding.UTF8 "./src/html/index.html" >>= HTTPure.ok
  | path !@ 0 == "js" ||
    path !@ 0 == "css"   = uploadJSorCSS path
serverHandler _          = HTTPure.notFound

uploadJSorCSS :: Array String -> HTTPure.ResponseM
uploadJSorCSS path = do
  let realPath = intercalate "/" $ "." : "src" : path
  fileExists <- FS.exists realPath

  let headers = HTTPure.header "Content-Type" $
                  if path !@ 0 == "js" then "text/javascript" else "text/css"

  if fileExists
  then FS.readTextFile Encoding.UTF8 realPath >>= HTTPure.ok' headers
  else HTTPure.notFound
