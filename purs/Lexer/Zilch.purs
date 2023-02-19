module Lexer.Zilch (zilchLexer) where

import CodeMirror
import Control.Monad
import Control.Monad

import Control.Monad.Cont (ContT(..), callCC, runContT)
import Control.Monad.Cont.Trans (lift)
import Control.Monad.Error.Class (class MonadThrow, liftEither)
import Data.Boolean (otherwise)
import Data.Either (Either(..))
import Data.Function (identity, ($))
import Data.Maybe (Maybe(..), maybe)
import Data.Monoid (mempty, (<>))
import Data.Nullable (Nullable, null, toNullable)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (ignoreCase, unicode)
import Data.Tuple (Tuple(..))
import Data.Unit (Unit, unit)
import Effect (Effect)
import Effect.Console (debugShow, error, info)
import Effect.Unsafe (unsafePerformEffect)
import Undefined (undefined)

keywords :: Either String Regex
keywords = regex "\\b(?:i(?:mport|f|nstance)|as(?:sume)?|op(?:en|aque)|public|l(?:et|am)|val|m(?:ut(?:ual)?|atch)|e(?:f{2}ect|num|lse)|re(?:c(?:ord(?:\\+|×|\\*)?)?|gion|sume)|constructor|t(?:ype|hen|rue)|w(?:ith|here)|λ|do|false|unsafe|notation)\\b" unicode

symbols :: Either String Regex
symbols = regex "(?::(=|:)?|≔|->|→|=>|⇒|×|⊗|&|⟨|⟩|∷|,)" unicode

builtins :: Either String Regex
builtins = regex "\\b(?:(?:(?:u|s)[0-9]+)|char|ptr|ref)\\b" unicode

identifier :: Either String Regex
identifier = regex "(?:_|\\p{L})(?:_|\\p{L}|\\p{N})*" (unicode <> ignoreCase)

--------------------------------------------------------------

tokenizeBuiltin :: StringStream -> Either String (Tuple StringStream (Maybe (Array Modifier)))
tokenizeBuiltin st = do
  builtins <- builtins
  Tuple st matched <- pure $ match builtins true false st
  pure
    if matched
    then Tuple st (Just [Standard TypeName])
    else Tuple st Nothing

tokenizeKeyword :: StringStream -> Either String (Tuple StringStream (Maybe (Array Modifier)))
tokenizeKeyword st = do
  keywords <- keywords
  Tuple st matched <- pure $ match keywords true false st
  pure
    if matched
    then Tuple st (Just [Keyword])
    else Tuple st Nothing

tokenizeSymbol :: StringStream -> Either String (Tuple StringStream (Maybe (Array Modifier)))
tokenizeSymbol st = do
  symbols <- symbols
  Tuple st matched <- pure $ match symbols true false st
  pure
    if matched
    then Tuple st (Just [Keyword])
    else Tuple st Nothing

tokenizeIdentifier :: StringStream -> Either String (Tuple StringStream (Maybe (Array Modifier)))
tokenizeIdentifier st = do
  identifier <- identifier
  Tuple st matched <- pure $ match identifier true false st
  pure
    if matched
    then Tuple st (Just [VariableName])
    else Tuple st Nothing

tokenizeStringChar :: StringStream -> Either String (Tuple StringStream (Maybe String))
tokenizeStringChar st = do
  backslash <- regex "\\\\" unicode
  Tuple st b1 <- pure $ eat backslash st
  Tuple st c <- pure $ next st
  pure $ Tuple st (concat b1 c)
  where
    concat Nothing Nothing = Nothing
    concat (Just _) Nothing = Nothing
    concat Nothing (Just c) = Just c
    concat (Just b) (Just c) = Just (b <> c)

tokenizeString :: StringStream -> Either String (Tuple StringStream (Maybe (Array Modifier)))
tokenizeString st = do
  guillemot <- regex "\"" mempty
  Tuple st eaten <- pure $ eat guillemot st
  case eaten of
    Nothing -> pure $ Tuple st Nothing
    Just _ -> do
      Tuple st hasEnd <- tryTokenizeStringInside guillemot st
      pure
        if hasEnd
        then Tuple st (Just [String])
        else Tuple st (Just [String, Error])
  where
    tryTokenizeStringInside guillemot st
      | eol st = pure $ Tuple st false
      | otherwise = do
        Tuple st hasEnd <- pure $ eat guillemot st
        case hasEnd of
          Just _ -> pure $ Tuple st true
          Nothing -> do
            Tuple st _ <- tokenizeStringChar st
            tryTokenizeStringInside guillemot st

tokenizeCharacter :: StringStream -> Either String (Tuple StringStream (Maybe (Array Modifier)))
tokenizeCharacter st = do
  guilsing <- regex "'" mempty
  Tuple st eaten <- pure $ eat guilsing st
  case eaten of
    Nothing -> pure $ Tuple st Nothing
    Just _ -> do
      Tuple st eaten <- tokenizeStringChar st
      case eaten of
        Nothing -> pure $ Tuple st (Just [String, Error])
        Just "'" -> pure $ Tuple st (Just [String, Error])
        Just _ -> do
          Tuple st eaten <- pure $ eat guilsing st
          case eaten of
            Nothing -> pure $ Tuple st (Just [String, Error])
            Just _ -> pure $ Tuple st (Just [String])

tokenizeNumber :: StringStream -> Either String (Tuple StringStream (Maybe (Array Modifier)))
tokenizeNumber st = do
  zero <- regex "0" mempty
  binDigit <- regex "[0-1]" mempty
  octDigit <- regex "[0-7]" mempty 
  decDigit <- regex "[0-9]" mempty
  hexDigit <- regex "[0-9a-f]" ignoreCase
  bee <- regex "b" ignoreCase
  oh <- regex "o" ignoreCase
  ex <- regex "x" ignoreCase

  Tuple st eaten <- pure $ eat zero st
  case eaten of
    Nothing -> do
      Tuple st eaten <- pure $ eatWhile decDigit st
      if eaten
      then pure $ Tuple st (Just [Number])
      else pure $ Tuple st Nothing
    Just _ -> do
      Tuple st eaten <- pure $ eat ex st
      case eaten of
        Nothing -> do
          Tuple st eaten <- pure $ eat oh st
          case eaten of
            Nothing -> do
              Tuple st eaten <- pure $ eat bee st
              case eaten of
                Nothing -> do
                  Tuple st eaten <- pure $ eatWhile decDigit st
                  pure $ Tuple st (Just [Number])
                Just _ -> do
                  Tuple st eaten <- pure $ eatWhile binDigit st
                  if eaten
                  then pure $ Tuple st (Just [Number])
                  else errorOut hexDigit st
            Just _ -> do
              Tuple st eaten <- pure $ eatWhile octDigit st
              if eaten
              then pure $ Tuple st (Just [Number])
              else errorOut hexDigit st
        Just _ -> do
          Tuple st eaten <- pure $ eatWhile hexDigit st
          if eaten
          then pure $ Tuple st (Just [Number])
          else errorOut hexDigit st
  where
    errorOut hexDigit st = do
      Tuple st _ <- pure $ eatWhile hexDigit st
      pure $ Tuple st (Just [Number, Error])

tokenizeLineComment :: StringStream -> Either String (Tuple StringStream (Maybe (Array Modifier)))
tokenizeLineComment st = do
  prefix <- regex "\\-{2} " mempty
  Tuple st eaten <- pure $ match prefix true false st
  if eaten
  then pure $ Tuple (skipToEnd st) (Just [Comment])
  else pure $ Tuple st Nothing

-----------------------------------------------

type Result = Tuple StringStream (Maybe (Array Modifier))
type Tokenizer = ContT Result (Either String) Result

-- instance errorCont :: (MonadThrow e m) => MonadThrow e (ContT r m) where
--   throwError = lift . throwError

token :: StringStream -> Tokenizer
token st = callCC \return -> do
  st <- lift (tokenizeLineComment st) >>= returnIfOk return
  st <- lift (tokenizeCharacter st) >>= returnIfOk return
  st <- lift (tokenizeString st) >>= returnIfOk return
  st <- lift (tokenizeKeyword st) >>= returnIfOk return
  st <- lift (tokenizeSymbol st) >>= returnIfOk return
  st <- lift (tokenizeBuiltin st) >>= returnIfOk return
  st <- lift (tokenizeIdentifier st) >>= returnIfOk return
  st <- lift (tokenizeNumber st) >>= returnIfOk return

  Tuple st _ <- pure (next st)
  return $ Tuple st Nothing
  where
    returnIfOk _ (Tuple st Nothing) = pure st
    returnIfOk return t@(Tuple _ (Just _)) = return t

token' :: StringStream -> Effect (Nullable (Array Modifier))
token' st = do
  case runContT (token st) Right of
    Left err -> null <$ error err
    Right (Tuple _ mods) -> pure (toNullable mods)

zilchLexer :: forall (st :: Type). StreamParser st
zilchLexer = { name: "Zilch", token: \st _ -> token' st }

-- foreign import setupZilchLexer :: Effect Unit
