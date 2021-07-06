module Server.Common where

import Data.Array as Array
import Data.Foldable (foldl)
import Data.Maybe (fromJust, Maybe(..), maybe)
import Data.Traversable (traverse)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Effect.Aff (Aff)
import Node.Buffer (Buffer)
import Node.FS.Aff as FS
import Partial.Unsafe (unsafePartial)
import Pathy (currentDir, parseRelDir, parseRelFile, posixParser, (</>), rootDir, sandbox, printPath, posixPrinter)
import Prelude

-- | Transforms a path according to the first function, and tries to read the file given
--   by prepending the current path.
--
--   The path must be a non-empty array of path elements.
--
--   Returns `Nothing` if file is not found, else `Just content`
readFile :: (Array String -> Array String) -> Array String -> Aff (Maybe Buffer)
readFile transformPath path = do
  let cwd = currentDir
  let newPath = transformPath path
  let { init, last } = unsafePartial fromJust $ Array.unsnoc newPath

  let dirs = traverse (\ dirName -> parseRelDir posixParser $ dirName <> "/") init
  let endFile = parseRelFile posixParser last

  let path = do
        dirs <- dirs
        endFile <- endFile
        let endPath = foldl (</>) cwd dirs </> endFile
        printPath posixPrinter <$> sandbox rootDir endPath

  flip (maybe $ pure Nothing) path $ \ p -> do
    let path = "." <> p
    fileExists <- FS.exists path

    if fileExists
    then Just <$> FS.readFile path
    else do
      liftEffect $ Console.warn $ "File not found:" <> path
      pure Nothing
