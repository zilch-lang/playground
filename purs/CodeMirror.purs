module CodeMirror (Modifier (..), StreamParser (..), StringStream, pos, start, string, indentUnit, eol, sol, peek, next, eat, eatWhile, eatSpace, skipToEnd, skipTo, backUp, column, indentation, match, match', current, fromParser) where
  
import Control.Monad

import Data.Array.NonEmpty (NonEmptyArray)
import Data.Function (($))
import Data.Function.Uncurried (Fn2, mkFn2)
import Data.Maybe (Maybe(..))
import Data.Monoid ((<>))
import Data.Nullable (Nullable, notNull, null, toMaybe)
import Data.Show (class Show, show)
import Data.String (joinWith)
import Data.String.Regex (Regex)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Console (info)
import Effect.Unsafe (unsafePerformEffect)

data Modifier
  = Comment
  | LineComment
  | BlockComment
  | DocComment
  | Name
  | VariableName
  | TypeName
  | TagName
  | PropertyName
  | AttributeName
  | ClassName
  | LabelName
  | Namespace
  | MacroName
  | Literal
  | String
  | DocString
  | Character
  | AttributeValue
  | Number
  | Integer
  | Float
  | Bool
  | Regexp
  | Escape
  | Color
  | URL
  | Keyword
  | Self
  | Null
  | Atom
  | Unit
  | Modifier
  | OperatorKeyword
  | ControlKeyword
  | DefinitionKeyword
  | ModuleKeyword
  | Operator
  | DerefOperator
  | ArithmeticOperator
  | LogicOperator
  | BitwiseOperator
  | CompareOperator
  | UpdateOperator
  | DefinitionOperator
  | TypeOperator
  | ControlOperator
  | Punctuation
  | Separator
  | Bracket
  | AngleBracket
  | SquareBracket
  | Paren
  | Brace
  | Content
  | Heading
  | Heading1
  | Heading2
  | Heading3
  | Heading4
  | Heading5
  | Heading6
  | ContentSeparator
  | List
  | Quote
  | Emphasis
  | Strong
  | Link
  | Monospace
  | StrikeThrough
  | Inserted
  | Deleted
  | Changed
  | Invalid
  | Meta
  | DocumentMeta
  | Annotation
  | ProcessingInstruction
  | Definition Modifier
  | Constant Modifier
  | Function Modifier
  | Standard Modifier
  | Local Modifier
  | Special Modifier
  | Error
  | Custom String

instance showModifier :: Show Modifier where
  show Comment = "comment"
  show LineComment = "lineComment"
  show BlockComment = "blockComment"
  show DocComment = "docComment"
  show Name = "name"
  show VariableName = "variableName"
  show TypeName = "typeName"
  show TagName = "tagName"
  show PropertyName = "propertyName"
  show AttributeName = "attributeName"
  show ClassName = "className"
  show LabelName = "labelName"
  show Namespace = "namespace"
  show MacroName = "macroName"
  show Literal = "literal"
  show String = "string"
  show DocString = "docString"
  show Character = "character"
  show AttributeValue = "attributeValue"
  show Number = "number"
  show Integer = "integer"
  show Float = "float"
  show Bool = "bool"
  show Regexp = "regexp"
  show Escape = "escape"
  show Color = "color"
  show URL = "url"
  show Keyword = "keyword"
  show Self = "self"
  show Null = "null"
  show Atom = "atom"
  show Unit = "unit"
  show Modifier = "modifier"
  show OperatorKeyword = "operatorKeyword"
  show ControlKeyword = "controlKeyword"
  show DefinitionKeyword = "definitionKeyword"
  show ModuleKeyword = "moduleKeyword"
  show Operator = "operator"
  show DerefOperator = "derefOperator"
  show ArithmeticOperator = "arithmeticOperator"
  show LogicOperator = "logicOperator"
  show BitwiseOperator = "bitwiseOperator"
  show CompareOperator = "compareOperator"
  show UpdateOperator = "updateOperator"
  show DefinitionOperator = "definitionOperator"
  show TypeOperator = "TypeOperator"
  show ControlOperator = "ControlOperator"
  show Punctuation = "punctuation"
  show Separator = "separator"
  show Bracket = "bracket"
  show AngleBracket = "angleBracket"
  show SquareBracket = "SquareBracket"
  show Paren = "paren"
  show Brace = "brace"
  show Content = "content"
  show Heading = "heading"
  show Heading1 = "heading1"
  show Heading2 = "heading2"
  show Heading3 = "heading2"
  show Heading4 = "heading4"
  show Heading5 = "heading5"
  show Heading6 = "heading6"
  show ContentSeparator = "contentSeparator"
  show List = "list"
  show Quote = "quote"
  show Emphasis = "emphasis"
  show Strong = "strong"
  show Link = "link"
  show Monospace = "monospace"
  show StrikeThrough = "strikethrough"
  show Inserted = "inserted"
  show Deleted = "deleted"
  show Changed = "changed"
  show Invalid = "invalid"
  show Meta = "meta"
  show DocumentMeta = "documentMeta"
  show Annotation = "annotation"
  show ProcessingInstruction = "processingInstruction"
  show (Definition m) = show m <> ".definition"
  show (Constant m) = show m <> ".constant"
  show (Function m) = show m <> ".function"
  show (Standard m) = show m <> ".standard"
  show (Local m) = show m <> ".local"
  show (Special m) = show m <> ".special"
  show Error = "error"
  show (Custom t) = t

type StreamParser (st :: Type) = { name :: String, token :: StringStream -> st -> Effect (Nullable (Array Modifier)) }

fromParser :: forall (st :: Type). StreamParser st -> { name :: String, token :: Fn2 StringStream st (Nullable String) }
fromParser {name: n, token: fn} = {name: n, token: mkFn2 \ss st -> unsafePerformEffect do
  mods <- toMaybe <$> fn ss st
  case mods of
    Nothing -> pure null
    Just mods -> pure $ notNull $ joinWith " " (show <$> mods) }

-----------------------------------

type Just = forall x. x -> Maybe x
type Nothing = forall x. Maybe x
type Pair = forall x y. x -> y -> Tuple x y

foreign import data StringStream :: Type 
foreign import posImpl :: StringStream -> Number
foreign import startImpl :: StringStream -> Number
foreign import stringImpl :: StringStream -> String
foreign import indentUnitImpl :: StringStream -> Number
foreign import eolImpl :: StringStream -> Boolean
foreign import solImpl :: StringStream -> Boolean
foreign import peekImpl :: StringStream -> Just -> Nothing -> Pair -> Tuple StringStream (Maybe String)
foreign import nextImpl :: StringStream -> Just -> Nothing -> Pair -> Tuple StringStream (Maybe String)
foreign import eatImpl :: Regex -> StringStream -> Just -> Nothing -> Pair -> Tuple StringStream (Maybe String)
foreign import eatWhileImpl :: Regex -> StringStream -> Pair -> Tuple StringStream Boolean
foreign import eatSpaceImpl :: StringStream -> Pair -> Tuple StringStream Boolean
foreign import skipToEndImpl :: StringStream -> StringStream
foreign import skipToImpl :: Char -> StringStream -> Just -> Nothing -> Pair -> Tuple StringStream (Maybe Boolean)
foreign import backUpImpl :: Number -> StringStream -> StringStream
foreign import columnImpl :: StringStream -> Number
foreign import indentationImpl :: StringStream -> Number
foreign import matchImpl :: Regex -> Boolean -> Boolean -> StringStream -> Pair -> Tuple StringStream Boolean
foreign import match_Impl :: Regex -> Boolean -> Boolean -> StringStream -> Just -> Nothing -> Pair -> Tuple StringStream (Maybe String)
foreign import currentImpl :: StringStream -> String

----------------------------------------------------

pos :: StringStream -> Number
pos = posImpl

start :: StringStream -> Number
start = startImpl

string :: StringStream -> String
string = stringImpl

indentUnit :: StringStream -> Number
indentUnit = indentUnitImpl

eol :: StringStream -> Boolean
eol = eolImpl

sol :: StringStream -> Boolean
sol = solImpl

peek :: StringStream -> Tuple StringStream (Maybe String)
peek st = peekImpl st Just Nothing Tuple

next :: StringStream -> Tuple StringStream (Maybe String)
next st = nextImpl st Just Nothing Tuple

eat :: Regex -> StringStream -> Tuple StringStream (Maybe String)
eat rg st = eatImpl rg st Just Nothing Tuple

eatWhile :: Regex -> StringStream -> Tuple StringStream Boolean
eatWhile rg st = eatWhileImpl rg st Tuple

eatSpace :: StringStream -> Tuple StringStream Boolean
eatSpace st = eatSpaceImpl st Tuple

skipToEnd :: StringStream -> StringStream
skipToEnd = skipToEndImpl

skipTo :: Char -> StringStream -> Tuple StringStream (Maybe Boolean)
skipTo c st = skipToImpl c st Just Nothing Tuple

backUp :: Number -> StringStream -> StringStream
backUp = backUpImpl

column :: StringStream -> Number
column = columnImpl

indentation :: StringStream -> Number
indentation = indentationImpl

match :: Regex -> Boolean -> Boolean -> StringStream -> Tuple StringStream Boolean
match rg consume caseInsensitive st = matchImpl rg consume caseInsensitive st Tuple

match' :: Regex -> Boolean -> Boolean -> StringStream -> Tuple StringStream (Maybe String)
match' rg consume caseInsensitive st = match_Impl rg consume caseInsensitive st Just Nothing Tuple

current :: StringStream -> String
current = currentImpl
