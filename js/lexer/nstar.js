(function() {
  "use strict"

  CodeMirror.defineMode("nstar", function() {
    const keywords = /\b(∀|forall|section|include)\b/u
    const builtinTypes = /\b(u[0-9]+|s[0-9]+)\b/u
    const registers = /%r[0-5]\b/u
    const instruction = /^(jmp|call|ret|s?ld|s?st|salloc|sfree|sref|mv|nop)$/iu

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

    function tokenizeInstruction(stream) {
      let res
      if (!(res = stream.match(/[a-z_][a-z0-9_]*/i, true)))
        return null

      return instruction.test(res) ? "header" : null
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

    const tokenizeRegister = (stream) => stream.match(registers, true) && "attribute"
    const tokenizeType = (stream) => stream.match(builtinTypes, true) && "type"
    const tokenizeKeyword = (stream) => stream.match(keywords, true) && "keyword"
    const tokenizeComment = (stream) => stream.eat("#") && (stream.skipToEnd(), "comment")

    const token = (stream) =>
          tokenizeComment(stream)
          || tokenizeCharacter(stream)
          || tokenizeString(stream)
          || tokenizeKeyword(stream)
          || tokenizeType(stream)
          || tokenizeRegister(stream)
          || tokenizeInstruction(stream)
          || tokenizeNumber(stream)
          || (stream.next(), null)
    
    return {
      token,
      lineComment: "#",
    }
  })
})()
