import tables
import options

type
    base_word* = proc(stack: var seq[int], dict: Table[string, string]):
        Option[string]

var
    base_words* = initTable[string, base_word]()

# helpers

proc words(stack: var seq[int], dict: Table[string, string]): Option[string] =
    for w in base_words.keys():
        stdout.write w & " "
    for w in dict.keys():
        stdout.write w & " "
base_words["words"] = words

# arithmetic

proc add(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    stack.add stack.pop() + stack.pop()
base_words["+"] = add

proc subtract(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    let n2 = stack.pop()
    let n1 = stack.pop()
    stack.add n1 - n2
base_words["-"] = subtract

proc multiply(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    stack.add stack.pop() * stack.pop()
base_words["*"] = multiply

proc divide(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    let n2 = stack.pop()
    let n1 = stack.pop()
    stack.add n1 div n2
base_words["/"] = divide

proc w_mod(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    let n2 = stack.pop()
    let n1 = stack.pop()
    stack.add n1 mod n2
base_words["mod"] = w_mod

# stack

proc dup(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 1: return some("stack underflow")
    stack.add stack[^1]
base_words["dup"] = dup

proc drop(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 1: return some("stack underflow")
    discard stack.pop()
base_words["drop"] = drop

proc swap(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    let n2 = stack.pop()
    let n1 = stack.pop()
    stack.add n2
    stack.add n1
base_words["swap"] = swap

proc over(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    stack.add stack[^2]
base_words["over"] = over

proc rot(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 3: return some("stack underflow")
    let n3 = stack.pop()
    let n2 = stack.pop()
    let n1 = stack.pop()
    stack.add n2
    stack.add n3
    stack.add n1
base_words["rot"] = rot

# output

proc dot(stack: var seq[int], dict: Table[string, string]): Option[string] =
    stdout.write stack.pop()
    stdout.write " "
base_words["."] = dot

proc emit(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 1: return some("stack underflow")
    stdout.write stack.pop().char
base_words["emit"] = emit

# TODO: define this in terms of .
proc puts(stack: var seq[int], dict: Table[string, string]): Option[string] =
    while true:
        if stack.len < 1: return some("stack underflow")
        let ch = stack.pop()
        if ch == 0: break
        stdout.write ch.char
base_words["puts"] = puts

# TODO: define this in terms of ,
proc cr(stack: var seq[int], dict: Table[string, string]): Option[string] =
    stdout.write "\n"
base_words["cr"] = cr

# bools

proc equals(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    stack.add if stack.pop() == stack.pop(): -1 else: 0
base_words["="] = equals

proc less(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    stack.add if stack.pop() > stack.pop(): -1 else: 0
base_words["<"] = less

proc greater(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    stack.add if stack.pop() < stack.pop(): -1 else: 0
base_words[">"] = greater

proc is_zero(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 1: return some("stack underflow")
    stack.add if stack.pop() == 0: -1 else: 0
base_words["0="] = is_zero

# bitwise (also works for bools)

proc w_and(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    stack.add stack.pop() and stack.pop()
base_words["and"] = w_and

proc w_or(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 2: return some("stack underflow")
    stack.add stack.pop() or stack.pop()
base_words["or"] = w_or

proc invert(stack: var seq[int], dict: Table[string, string]): Option[string] =
    if stack.len < 1: return some("stack underflow")
    stack.add not stack.pop()
base_words["invert"] = invert