import { fromParser } from './output/CodeMirror/index.js'
import { zilchLexer } from './output/Lexer.Zilch/index.js'
import { nstarLexer } from './output/Lexer.NStar/index.js'

CodeMirror.defineMode("zilch", () => fromParser(zilchLexer))
CodeMirror.defineMode("nstar", () => fromParser(nstarLexer))
