module Server (runServer) where

import CLI (CLI)
import Effect.Console as Console
import HTTPure as HTTPure
import Prelude
import Server.Router (serverRouter)

-- | Runs the server on the given port.
runServer :: CLI -> HTTPure.ServerM
runServer { port } = HTTPure.serve port serverRouter do
  Console.log $ "Server running on port " <> show port <> "."
