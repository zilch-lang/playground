module Server.Routes.PNG (runRoute) where

import Data.Array ((:))
import Data.Array as Array
import Data.Maybe (maybe, fromJust)
import HTTPure as HTTPure
import Partial.Unsafe (unsafePartial)
import Prelude
import Server.Common (readFile)

runRoute :: Array String -> HTTPure.ResponseM
runRoute path = readFile moveIntoAssets path >>= maybe HTTPure.notFound (HTTPure.ok' $ HTTPure.header "Content-Type" "image/png")
  where
    moveIntoAssets p = "assets" : unsafePartial fromJust (Array.tail p)
