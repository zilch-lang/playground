module Server (runServer) where

import Ansi.Codes (Color(..)) as ANSI
import Ansi.Output (bold, foreground, underline, withGraphics) as ANSI
import CLI (CLI)
import Effect.Aff (launchAff_, apathize)
import Effect.Console as Console
import HTTPure as HTTPure
import Node.FS.Aff as FS
import Prelude
import Server.Router (serverRouter)

-- | Runs the server on the given port.
runServer :: CLI -> HTTPure.ServerM
runServer cli@{ port, outDir, gzcExe, gccExe } =
  HTTPure.serve port (serverRouter cli) do
    Console.log $ ANSI.withGraphics (ANSI.underline <> ANSI.bold) "Server configuration:"
    Console.log $ "- gzc executable:    " <> ANSI.withGraphics (ANSI.foreground ANSI.Blue) gzcExe
    Console.log $ "- gcc executable:    " <> ANSI.withGraphics (ANSI.foreground ANSI.Blue) gccExe
    Console.log $ "- output directory:  " <> ANSI.withGraphics (ANSI.foreground ANSI.Blue) outDir
    Console.log $ "- port:              " <> ANSI.withGraphics (ANSI.foreground ANSI.Blue) (show port)

    launchAff_ $ apathize do
      FS.mkdir outDir
      -- outExists <- FS.exists outDir
      -- unless outExists do
