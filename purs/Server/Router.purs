module Server.Router (serverRouter) where

import Data.Array as Array
import HTTPure ((!@))
import HTTPure as HTTPure
import Prelude
import Server.Routes.Compile as Compile
import Server.Routes.CSS as CSS
import Server.Routes.Index as Index
import Server.Routes.JS as JS
import Server.Routes.PNG as PNG

-- | Handles requests coming to the server.
serverRouter :: HTTPure.Request -> HTTPure.ResponseM
serverRouter { method: HTTPure.Get, path }
  | Array.null path        = Index.runRoute
  | path !@ 0 == "js"      = JS.runRoute path
  | path !@ 0 == "css"     = CSS.runRoute path
  | path !@ 0 == "png"     = PNG.runRoute path
serverRouter { method: HTTPure.Post, path, body }
  | path !@ 0 == "compile" = Compile.runRoute body
serverRouter _             = HTTPure.notFound
