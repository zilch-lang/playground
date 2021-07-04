module Main where

import CLI (cliMain)
import HTTPure as HTTPure
import Server (runServer)


-- | Main function, running the command-line arguments parser
--   and the server.
main :: HTTPure.ServerM
main = cliMain runServer
