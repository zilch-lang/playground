"use strict";

export const backUpImpl = st => n => st.backUp(n)

export const columnImpl = st => st.column()

export const currentImpl = st => st.current()

export const eatImpl = rg => st => just => nothing => pair => {
  let eaten = st.eat(rg)
  if (eaten === undefined)
    return pair(st)(nothing)
  else
    return pair(st)(just(eaten))
}

export const eatSpaceImpl = st => pair => {
  let eaten = st.eatSpace()
  return pair(st)(eaten)
}

export const eatWhileImpl = rg => st => pair => {
  let eaten = st.eatWhile(rg)
  return pair(st)(eaten)
}

export const eolImpl = st => st.eol()

export const indentUnitImpl = st => st.indentUnit

export const indentationImpl = st => st.indentation()

export const matchImpl = rg => consume => caseInsensitive => st => pair => {
  let eaten = !!st.match(rg, consume, caseInsensitive)
  return pair(st)(eaten)
}

export const match_Impl = rg => consume => caseInsensitive => st => just => nothing => pair => {
	let eaten = st.match(rg, consume, caseInsensitive)
	if (eaten === null)
	  return pair(st)(nothing)
	else if (typeof(eaten) === "object")
	  return pair(st)(just(eaten[0]))
	else
	  return pair(st)(nothing)
}

export const nextImpl = st => just => nothing => pair => {
  let eaten = st.next()
  if (eaten === undefined)
    return pair(st)(nothing)
  else
    return pair(st)(just(eaten))
}

export const peekImpl = st => just => nothing => pair => {
  let peeked = st.peek()
  if (peeekd === undefined)
    return pair(st)(nothing)
  else
    return pair(st)(just(peeked))
}

export const posImpl = st => st.pos

export const skipToEndImpl = st => {
  st.skipToEnd()
  return st
}

export const skipToImpl = c => st => just => nothing => pair => {
  let reached = st.skipTo(c)
  if (reached === undefined)
    return pair(st)(nothing)
  else
    return pair(st)(just(reached))
}

export const solImpl = st => st.sol()

export const startImpl = st => st.start

export const stringImpl = st => st.string
