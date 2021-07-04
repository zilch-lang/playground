module Server.Routes.JS (runRoute) where

import Data.Maybe (maybe)
import HTTPure as HTTPure
import Prelude
import Server.Common (readFile)

runRoute :: Array String -> HTTPure.ResponseM
runRoute path = readFile identity path >>= maybe HTTPure.notFound (HTTPure.ok' $ HTTPure.header "Content-Type" "text/javascript")
