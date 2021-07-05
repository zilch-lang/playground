module Server (runServer) where

import CLI (CLI)
import Effect.Aff (launchAff_)
import Effect.Console as Console
import HTTPure as HTTPure
import Node.FS.Aff as FS
import Prelude
import Server.Router (serverRouter)

-- | Runs the server on the given port.
runServer :: CLI -> HTTPure.ServerM
runServer { port } =
  let outDir = "./out"
  in HTTPure.serve port (serverRouter outDir) do
    launchAff_ do
      outExists <- FS.exists outDir
      unless outExists do
        FS.mkdir outDir
    Console.log $ "Server running on port " <> show port <> "."
