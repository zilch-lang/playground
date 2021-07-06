module Server.Routes.Index (runRoute) where

import Effect.Aff (Aff)
import HTTPure as HTTPure
import Node.Encoding as Encoding
import Node.FS.Aff as FS
import Prelude

runRoute :: HTTPure.ResponseM
runRoute = FS.readFile "./html/index.html" >>= HTTPure.ok
