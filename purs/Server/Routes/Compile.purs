module Server.Routes.Compile (runRoute) where

import Ansi.Codes (Color(..)) as ANSI
import Ansi.Output (bold, foreground, withGraphics) as ANSI
import CLI (CLI)
import Control.Monad.Except (ExceptT, runExceptT, throwError)
import Control.Monad.Trans.Class (class MonadTrans, lift)
import Control.Monad.Writer (WriterT, runWriterT, tell)
import Data.Argonaut (parseJson, stringify)
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Bifunctor (lmap)
import Data.Bifoldable (bifold)
import Data.Either (fromRight, Either(..), note, either)
import Data.Maybe (Maybe(..))
import Data.Posix.Signal (Signal(SIGTERM))
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested(Tuple3, tuple3, uncurry3)
import Data.UUID (genUUID)
import Data.UUID (toString) as UUID
import Effect.Aff (makeAff, Canceler(..), Aff, apathize, attempt)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Effect.Exception (message)
import HTTPure as HTTPure
import Node.Buffer as Buffer
import Node.ChildProcess as CP
import Node.Encoding as Encoding
import Node.FS.Aff as FS
import Prelude

type Compile a = ExceptT Unit (WriterT (Tuple3 String String String) Aff) a

-- | Compiles some Zilch code and returns, as JSON:
--
--   * `{ "fail": true, "stdout": "...", "stderr": "..." }` if the code failed to compile
--   * `{ "fail": false, "stdout": "...", "stderr": "..." }` if the code compiled successfully and executed
runRoute :: CLI -> String -> HTTPure.ResponseM
runRoute cli body = do
  Tuple hasError res <- runWriterT $ runExceptT (compileCode cli body)

  HTTPure.ok' (HTTPure.header "Content-Type" "application/json")
              (stringify $ encodeJson $ uncurry3 { fail: either (const true) (const false) hasError, stdout: _, stderr: _, nstar: _ } res)

compileCode :: CLI -> String -> Compile Unit
compileCode { gzcExe, gccExe, outDir } body = do
  let { code } = fromRight { code: "" } $ decodeJson =<< parseJson body

  uuid <- lift2 $ liftEffect genUUID
  let file_zc  = outDir <> "/" <> UUID.toString uuid <> ".zc"
      file_nst = outDir <> "/" <> UUID.toString uuid <> ".nst"
      file_o   = file_zc <> ".o"
      file_out = file_o <> ".out"

  lift2 do
    FS.writeTextFile Encoding.UTF8 file_zc code

  startProcess gzcExe ["-ddump-nstar", "--output", file_o, "--ddump-dir", outDir, file_zc] compileOptions
    \ _ -> lift2 $ apathize $ FS.unlink file_zc

  nstar <- lift2 $ (bifold <<< lmap (const "")) <$> attempt (FS.readTextFile Encoding.UTF8 file_nst)
  tell (tuple3 "" "" nstar)

  startProcess gccExe ["--output", file_out, file_o] compileOptions
    \ _ -> lift2 $ apathize $ FS.unlink file_o

  startProcess file_out [] execOptions
    \ _ -> lift2 $ apathize $ FS.unlink file_out

  pure unit
  where
    compileOptions = CP.defaultExecOptions
      { timeout   = Just 180.0    -- 3 minutes
      , maxBuffer = Just 26214400 -- 25 MiB
      }
    execOptions = CP.defaultExecOptions
      { timeout   = Just 60.0     -- 1 minute
      , maxBuffer = Just 26214400 -- 25 MiB
      }


-- | Starts a process given its name/path, its arguments, some execution options and a function to call on command completion.
startProcess :: String
             -> Array String
             -> CP.ExecOptions
             -> (CP.ExecResult -> Compile Unit)
             -> Compile Unit
startProcess program args execOptions cont = do
  res@{ stdout, stderr, error } <- lift2 $ makeAff \ cb -> do
    proc <- CP.execFile program args execOptions \ result -> cb (Right result)

    pure $ Canceler \ _ -> liftEffect $ CP.kill SIGTERM proc

  tup <- lift2 $ liftEffect do
    tuple3 <$> Buffer.toString Encoding.UTF8 stdout
           <*> Buffer.toString Encoding.UTF8 stderr
           <*> pure ""
  tell tup

  cont res

  case swapEither $ note unit error of
    Left e -> do
      lift2 $ liftEffect $ Console.error $ ANSI.withGraphics (ANSI.bold <> ANSI.foreground ANSI.Red) (message e)
      throwError unit
    Right _ -> pure unit



-- | Swaps the left and the right component of an `Either` value.
swapEither :: forall a b. Either a b -> Either b a
swapEither (Left x)  = Right x
swapEither (Right x) = Left x

lift2 :: forall t t' m a
      .  Monad m
      => MonadTrans t
      => MonadTrans t'
      => Monad (t' m)
      => m a
      -> t (t' m) a
lift2 = lift <<< lift
