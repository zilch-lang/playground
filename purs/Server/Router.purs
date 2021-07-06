module Server.Router (serverRouter) where

import CLI (CLI)
import Data.Array as Array
import HTTPure ((!@))
import HTTPure as HTTPure
import Prelude
import Server.Routes.Compile as Compile
import Server.Routes.CSS as CSS
import Server.Routes.ICO as ICO
import Server.Routes.Index as Index
import Server.Routes.JS as JS
import Server.Routes.PNG as PNG

-- | Handles requests coming to the server.
serverRouter :: CLI -> HTTPure.Request -> HTTPure.ResponseM
serverRouter _ { method: HTTPure.Get, path }
  | Array.null path        = Index.runRoute
  | path !@ 0 == "js"      = JS.runRoute path
  | path !@ 0 == "css"     = CSS.runRoute path
  | path !@ 0 == "png"     = PNG.runRoute path
  | path !@ 0 == "ico"     = ICO.runRoute path
serverRouter cli { method: HTTPure.Post, path, body }
  | path !@ 0 == "compile" = Compile.runRoute cli body
serverRouter _ _           = HTTPure.notFound
