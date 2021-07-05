module Server.Routes.Compile (runRoute) where

import CLI (CLI)
import Control.Monad.Except (ExceptT, runExceptT, throwError)
import Control.Monad.Trans.Class (lift)
import Data.Argonaut (parseJson, stringify)
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Bifoldable (bifold)
import Data.DateTime.Instant (unInstant)
import Data.Either (fromRight, Either(..), note)
import Data.Maybe (Maybe(..))
import Data.Posix.Signal (Signal(SIGTERM))
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (makeAff, Canceler(..), Aff)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Effect.Now (now)
import HTTPure as HTTPure
import Node.Buffer as Buffer
import Node.ChildProcess as CP
import Node.Encoding as Encoding
import Node.FS.Aff as FS
import Prelude

type ZilchCode = { code :: String }

type CompileResult = { fail :: Boolean, stdout :: String, stderr :: String }

-- | Compiles some Zilch code and returns, as JSON:
--
--   * `{ "fail": true, "stdout": "...", "stderr": "..." }` if the code failed to compile
--   * `{ "fail": false, "stdout": "...", "stderr": "..." }` if the code compiled successfully and executed
runRoute :: CLI -> String -> HTTPure.ResponseM
runRoute cli body = do
  res <- runExceptT (compileCode cli body)
  HTTPure.ok' (HTTPure.header "Content-Type" "application/json") (bifold res)

compileCode :: CLI -> String -> ExceptT String Aff String
compileCode { gzcExe, gccExe, outDir } body = do
  let { code } = fromRight { code: "" } $ decodeJson =<< parseJson body

  Milliseconds ms <- lift $ unInstant <$> liftEffect now
  let timestampFile = outDir <> "/" <> show ms <> ".zc"
  lift $ FS.writeTextFile Encoding.UTF8 timestampFile code

  res1 <- lift $ makeAff \ cb -> do
    proc <- CP.execFile gzcExe ["-ddump-nstar", "--output=" <> timestampFile <> ".o", timestampFile] compileOptions \ result -> cb (Right result)

    pure $ Canceler \ _ -> liftEffect $ CP.kill SIGTERM proc

  res1' <- lift $ liftEffect do
    { stdout: _, stderr: _ }
      <$> Buffer.toString Encoding.UTF8 res1.stdout
      <*> Buffer.toString Encoding.UTF8 res1.stderr

  lift $ FS.unlink timestampFile

  case swapEither $ note unit res1.error of
    Left e  -> do
      lift $ liftEffect $ Console.log $ show e
      throwError $ stringify $ encodeJson { fail: true, stdout: res1'.stdout, stderr: res1'.stderr }
    Right _ -> pure unit

  res2 <- lift $ makeAff \ cb -> do
    proc <- CP.execFile gccExe ["--output=" <> timestampFile <> ".out", timestampFile <> ".o"] compileOptions \ result -> cb (Right result)

    pure $ Canceler \ _ -> liftEffect $ CP.kill SIGTERM proc

  res2' <- lift $ liftEffect do
    { stdout: _, stderr: _ }
      <$> ((res1'.stdout <> _) <$> Buffer.toString Encoding.UTF8 res2.stdout)
      <*> ((res1'.stderr <> _) <$> Buffer.toString Encoding.UTF8 res2.stderr)

  case swapEither $ note unit res2.error of
    Left e -> do
      lift $ liftEffect $ Console.log $ show e
      throwError $ stringify $ encodeJson { fail: true, stdout: res2'.stdout, stderr: res2'.stderr }
    Right _ -> pure unit

  lift $ FS.unlink (timestampFile <> ".o")

  -- TODO: check if command errored out

  -- TODO: run executable

  lift $ FS.unlink (timestampFile <> ".out")

  pure $ stringify $ encodeJson { fail: false, stdout: res2'.stdout, stderr: res2'.stderr }
  where
    compileOptions = CP.defaultExecOptions
      { timeout   = Just 180.0    -- 3 minutes
      , maxBuffer = Just 26214400 -- 25 MiB
      }
    execOptions = CP.defaultExecOptions
      { timeout   = Just 60.0     -- 1 minute
      , maxBuffer = Just 26214400 -- 25 MiB
      }

-- | Swaps the left and the right component of an `Either` value.
swapEither :: forall a b. Either a b -> Either b a
swapEither (Left x)  = Right x
swapEither (Right x) = Left x
