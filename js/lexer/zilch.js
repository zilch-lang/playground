(function() {
  "use strict"

  CodeMirror.defineMode("zilch", function() {
    const keywords = /\b(foral{2}|∀|e(num|lse|xport|f{2}ect)|rec(ord)?|c(ase|las{2})|imp(l|ort)|where|a(lia)?s|o(f|pen)|module|i[fn]|then|pat{2}ern|let)\b/u
    const symbols = /:(=)?|(-)?>|→|_|·|≔|\?|\||<|\{|\}/u
    const builtins = /(eff|type|(u|s)[0-9]+|char|ptr|ref)/u

    const tokenizeBuiltin = (stream) => stream.match(builtins, true) && "attribute"
    const tokenizeIdentifier = (stream) => stream.match(/(_|\p{L})(_|\p{L}|\p{N})*/iu, true) && "variable"
    const tokenizeSymbol = (stream) => stream.match(symbols, true) && "keyword"
    const tokenizeKeyword = (stream) => stream.match(keywords, true) && "keyword"
    const tokenizeStringChar = (stream) => (stream.eat("\\"), stream.eat(/./u))

    function tokenizeString(stream) {
      if (!stream.eat('"'))
        return null

      let end
      while (!stream.eol() && !(end = stream.eat('"'))) {
        tokenizeStringChar(stream)
      }

      return !end ? "string error" : "string"
    }

    function tokenizeCharacter(stream) {
      if (!stream.eat("'"))
        return null

      tokenizeStringChar(stream)

      return stream.eat("'") ? "string" : "string error"
    }

    function tokenizeNumber(stream) {
      if (stream.eat("0")) {
        if (stream.eat(/x/i)) {
          return !!stream.eatWhile(/[0-9a-f]/) ? "number" : "number error"
        } else if (stream.eat(/o/i)) {
          return !!stream.eatWhile(/[0-7]/) ? "number"
                                            : (stream.eatWhile(/[0-9a-f]/i), "number error")
        } else if (stream.eat(/b/i)) {
        return !!stream.eatWhile(/0|1/) ? "number"
                                          : (stream.eatWhile(/[0-9a-f]/i), "number error")
        } else {
          return stream.eatWhile(/[0-9]/), "number"
        }
      } else if (stream.eatWhile(/[0-9]/)) {
        return "number"
      } else {
        return null
      }
    }

    const tokenizeComment = (stream) => stream.match("--", true) && (stream.skipToEnd(), "comment")

    const token = (stream) =>
          tokenizeComment(stream)
          || tokenizeCharacter(stream)
          || tokenizeString(stream)
          || tokenizeKeyword(stream)
          || tokenizeSymbol(stream)
          || tokenizeBuiltin(stream)
          || tokenizeIdentifier(stream)
          || tokenizeNumber(stream)
          || (stream.next(), null)

    return {
      token,
      lineComment: "--",
    }
  })
})()
