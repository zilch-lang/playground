(function() {
  "use strict"

  CodeMirror.defineMode("nstar", function() {
    const keywords = /\b(∀|forall|section|include)\b/u
    const builtinTypes = /\b(u[0-9]+|s[0-9]+)\b/u
    const registers = /%r[0-5]\b/u
    const instruction = /^(jmp|call|ret|s?ld|s?st|salloc|sfree|sref|mv|nop)$/iu

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

    function tokenizeInstruction(stream) {
      let res
      if (!(res = stream.match(/[a-z_][a-z0-9_]*/i, true)))
        return ""

      return instruction.test(res) ? "header" : ""
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

    function tokenizeRegister(stream) {
      return stream.match(registers, true) && "attribute"
    }

    function tokenizeType(stream) {
      return stream.match(builtinTypes, true) && "type"
    }

    function tokenizeKeyword(stream) {
      return stream.match(keywords, true) && "keyword"
    }

    function tokenizeComment(stream) {
      return stream.eat("#") && (stream.skipToEnd(), "comment")
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
      if (tokenType = tokenizeType(stream))
        return tokenType
      if (tokenType = tokenizeRegister(stream))
        return tokenType
      if (tokenType = tokenizeInstruction(stream))
        return tokenType
      if (tokenType = tokenizeNumber(stream))
        return tokenType

      return stream.next(), null
    }
    
    return {
      token,
      lineComment: "#",
    }
  })
})()
