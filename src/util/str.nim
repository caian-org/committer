import std/terminal

func substring* (t: string, s: int, e: int): string = t[s..e]

func toColor* (t: string, color: ForegroundColor, bright: bool): string =
  ansiForegroundColorCode(color, bright = bright) & t & ansiResetCode

func toBrightCyanColor* (t: string): string =
  t.toColor(fgCyan, true)

func toBoldStyle* (t: string): string =
  ansiStyleCode(styleBright) & t & ansiResetCode
