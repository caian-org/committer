import std/osproc
import std/random
import std/strutils
import std/sequtils
import std/strutils
import std/sugar

const
  loremIpsum = @["lorem", "ipsum", "dolor", "sit", "amet", "consectetur",
  "adipiscing", "elit", "morbi", "efficitur", "libero", "vitae", "congue",
  "blandit", "orci", "sem", "semper", "purus", "ac", "mattis", "eros", "mi",
  "quis", "magna", "mauris", "id", "turpis", "iaculis", "pulvinar", "ut",
  "porta", "dui", "duis", "faucibus", "augue", "eget", "laoreet", "etiam",
  "eu", "a", "metus", "scelerisque", "bibendum", "non", "lacus", "sed",
  "feugiat", "nibh", "suscipit", "ante", "in", "hac", "habitasse", "platea",
  "dictumst", "cras", "cursus", "lectus", "finibus", "rhoncus", "quam",
  "justo", "tincidunt", "urna", "et", "integer", "fringilla", "at", "odio",
  "consequat", "suspendisse", "interdum", "nulla", "gravida", "pellentesque",
  "pharetra", "velit", "elementum", "vulputate", "maximus", "nisi", "nunc",
  "nullam", "sapien", "posuere", "dictum", "praesent", "dapibus",
  "sollicitudin", "vivamus", "venenatis", "risus", "varius", "donec",
  "aliquam", "quisque", "pretium", "commodo", "nec", "vel", "condimentum",
  "nisl", "facilisis", "tristique", "euismod", "est", "fusce", "volutpat",
  "enim", "lacinia", "hendrerit", "accumsan", "mollis", "imperdiet", "tempor",
  "ullamcorper", "porttitor", "diam", "tellus", "vestibulum", "neque",
  "sodales", "class", "aptent", "taciti", "sociosqu", "ad", "litora",
  "torquent", "per", "conubia", "nostra", "inceptos", "himenaeos", "nam",
  "auctor", "phasellus", "eleifend", "ultricies", "dignissim", "rutrum"]

type
  CommitOpts = object
    includeBody : bool
    wrapText    : bool

randomize()


# ...
func times [T](amount: int, f: () -> T): seq[T] =
  var a: seq[int] = @[]
  for i in 0..amount:
    a.add(0)

  return a.map((_) => f())

proc execCmd (cmd: string, panicOnError = true): (string, int) =
  let (output, exitCode) = execCmdEx(cmd)

  if panicOnError and exitCode > 0:
    let co = if len(output) > 0: format("; got:\n\n$1", output) else: ""
    let msg = format("command '$1' failed with return code $2", cmd, exitCode) & co

    raise newException(Defect, msg)

  return (output, exitCode)


# ...
proc getIpsumWord (): string =
  loremIpsum[rand(len(loremIpsum) - 1)]

proc getCommitMessage (): string =
  var phrase = rand(3..9)
    .times(() => getIpsumWord() & (if rand(0..7) == 0: "," else: ""))
    .join(" ")

  if len(phrase) > 79:
    phrase = phrase[0..79]

  if phrase.endsWith(","):
    phrase = phrase[0..(len(phrase) - 2)]

  return phrase

# ...
proc main () =
  let commitAmount = rand(10..20)

  echo ""
  for i in 1..commitAmount:
    echo getCommitMessage()

when isMainModule:
  main()
