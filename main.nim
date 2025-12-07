import algorithm
import strutils
import rdstdin
import options
import tables

import builtins

type
    words = seq[string]

let
    decimalChars = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
    hexChars = decimalChars + {'A', 'B', 'C', 'D', 'E', 'F',
                               'a', 'b', 'c', 'd', 'e', 'f'}
    binChars = {'0', '1'}

var
    dictionary = initTable[string, string]()

    stack: seq[int] = @[]

    loopStack: seq[uint] = @[]

proc run_snippet(snippet: string): bool =
  let words = snippet.splitWhitespace()
  var i = 0

  while i < words.len:
    let word = words[i]

    if word.len == 3 and word.startsWith('\'') and word.endsWith('\''):
      stack.add word[1].int

    elif word.startsWith('"') and word.endsWith('"') and word.len > 2:
      stack.add 0
      for ch in word[1..^2].reversed():
        stack.add ch.int

    elif word.startsWith("0x") and word[2..^1].allCharsInSet(hexChars):
      stack.add word.fromHex[:int]

    elif word.startsWith("0b") and word[2..^1].allCharsInSet(binChars):
      stack.add word.fromBin[:int]

    elif word.allCharsInSet(decimalChars):
      stack.add word.replace("_", "").parseInt()

    elif word == ":":
      if i + 1 >= words.len:
        stderr.write ":( expected word name after ':'"
        return false

      let name = words[i + 1]
      var j = i + 2
      var nestedColon = 0

      while j < words.len:
        if words[j] == ":":
          nestedColon += 1
        elif words[j] == ";" :
          if nestedColon == 0:
            break
          else:
            nestedColon -= 1
        j += 1

      if j == words.len:
        stderr.write ":( unmatched ':'"
        return false

      let snippet = words[i + 2 .. j - 1].join(" ")
      dictionary[name] = snippet
      i = j

    elif word == "if":
      if stack.len < 1:
        stderr.write ":( stack underflow for if"
        return false

      let cond = stack.pop()
      var j = i + 1
      var nestedIf = 0
      var elsePos = -1

      while j < words.len:
        if words[j] == "if":
          nestedIf += 1
        elif words[j] == "then":
          if nestedIf == 0:
            break
          else:
            nestedIf -= 1
        elif words[j] == "else" and nestedIf == 0:
          elsePos = j
        j += 1

      if j == words.len:
        stderr.write ":( unmatched if"
        return false

      if cond != 0:
        let start = i + 1
        let final = if elsePos == -1: j - 1 else: elsePos - 1
        let snippet = words[start .. final].join(" ")
        if not run_snippet(snippet):
          return false
      else:
        if elsePos != -1:
          let snippet = words[elsePos + 1 .. j - 1].join(" ")
          if not run_snippet(snippet):
            return false

      i = j

    elif word == "do":
        if stack.len < 2:
            stderr.write ":( stack underflow for do"
            return false

        let startIdx = stack.pop()
        let endIdx = stack.pop()
        var j = i + 1
        var nestedDo = 0

        while j < words.len:
            if words[j] == "do":
                nestedDo += 1
            elif words[j] == "loop":
                if nestedDo == 0:
                    break
                else:
                    nestedDo -= 1
            j += 1

        if j == words.len:
            stderr.write ":( unmatched do"
            return false

        for idx in startIdx ..< endIdx:
            loopStack.add(idx.uint)
            let snippet = words[i + 1 .. j - 1].join(" ")
            if not run_snippet(snippet):
                return false
            discard loopStack.pop()


        i = j

    elif word == "i":
        if loopStack.len == 0:
            stderr.write ":( accessed i outside a loop"
            return false
        stack.add loopStack[^1].int

    elif word == "begin":
        var j = i + 1
        var nestedBegin = 0
        while j < words.len:
            if words[j] == "begin":
                nestedBegin += 1
            elif words[j] == "until":
                if nestedBegin == 0:
                    break
                else:
                    nestedBegin -= 1
            j += 1

        if j == words.len:
            stderr.write ":( unmatched begin"
            return false

        let snippet = words[i + 1 .. j - 1].join(" ")

        while true:
            if not run_snippet(snippet):
                return false
            if stack.len < 1:
                stderr.write ":( stack underflow for until"
                return false
            let cond = stack.pop()
            if cond != 0:
                break

        i = j

    elif dictionary.hasKey(word):
        if not run_snippet(dictionary[word]):
            return false

    else:
        if not base_words.hasKey(word):
                stderr.write ":( [" & word & "?]"
                return false
        let errMsg = base_words[word](stack, dictionary)
        if errMsg.isSome:
            stderr.write ":( " & errMsg.get()
            return false
      

    i += 1

  return true

proc printStack() =
    stdout.write "| "
    for i in stack:
        stdout.write i
        stdout.write " "
    echo "~"

proc repl() =
    while true:
        printStack()
        let command = readLineFromStdin("> ")
        discard run_snippet(command)
        echo ""

if isMainModule:
    repl()
