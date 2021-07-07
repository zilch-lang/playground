(function() {
  "use strict"

  CodeMirror.defineMode("zilch", function() {
    const keywords = /\b(foral{2}|∀|e(num|lse|xport|f{2}ect)|rec(ord)?|c(ase|las{2})|imp(l|ort)|where|a(lia)?s|o(f|pen)|module|i[fn]|then|pat{2}ern|let)\b/u
    const symbols = /:(=)?|(-)?>|→|_|·|≔|\?|\||<|\{|\}/u
    const builtins = /(eff|type|(u|s)[0-9]+|char|ptr|ref)/u

    function tokenizeBuiltin(stream) {
      return stream.match(builtins, true) && "attribute"
    }

    function tokenizeIdentifier(stream) {
      return stream.match(/(_|\p{L})(_|\p{L}|\p{N})*/iu, true) && "variable"
    }

    function tokenizeSymbol(stream) {
      return stream.match(symbols, true) && "keyword"
    }

    function tokenizeKeyword(stream) {
      return stream.match(keywords, true) && "keyword"
    }

    function tokenizeStringChar(stream) {
      stream.eat("\\")
      stream.eat(/./u)
    }

    function tokenizeString(stream) {
      if (!stream.eat('"'))
        return ""

      let end
      while (!stream.eol() && !(end = stream.eat('"'))) {
        tokenizeStringChar(stream)
      }

      return !end ? "string error" : "string"
    }

    function tokenizeCharacter(stream) {
      if (!stream.eat("'"))
        return ""

      tokenizeStringChar(stream)

      if (!stream.eat("'"))
        return "string error"
      return "string"
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
        return ""
      }
    }

    function tokenizeComment(stream) {
      return stream.match("--", true) && (stream.skipToEnd(), "comment")
    }

    function token(stream) {
      let tokenType

      if (tokenType = tokenizeComment(stream))
        return tokenType
      if (tokenType = tokenizeCharacter(stream))
        return tokenType
      if (tokenType = tokenizeString(stream))
        return tokenType
      if (tokenType = tokenizeKeyword(stream))
        return tokenType
      if (tokenType = tokenizeSymbol(stream))
        return tokenType
      if (tokenType = tokenizeBuiltin(stream))
        return tokenType
      if (tokenType = tokenizeIdentifier(stream))
        return tokenType
      if (tokenType = tokenizeNumber(stream))
        return tokenType

      return stream.next(), null
    }

    return {
      token,
      lineComment: "--",
    }
  })
})()
