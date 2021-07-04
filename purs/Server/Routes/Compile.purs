module Server.Routes.Compile (runRoute) where

import Data.Argonaut (parseJson)
import Data.Argonaut.Decode (decodeJson)
import Data.Either (fromRight)
import HTTPure as HTTPure
import Node.ChildProcess (ChildProcess)
import Node.ChildProcess as CP
import Prelude

type ZilchCode = { code :: String }

-- | Compiles some Zilch code and returns, as JSON:
--
--   * `{ "fail": true, "error": "error string" }` if the code failed to compile
--   * `{ "fail": false, "timeout": true | false, "stdout": "...", "stderr": "..."}` if the code compiled successfully and executed
runRoute :: String -> HTTPure.ResponseM
runRoute body = do
  let (result :: ZilchCode) = fromRight { code: "" } $ decodeJson =<< parseJson body

  HTTPure.ok' (HTTPure.header "Content-Type" "application/json") "{}"
