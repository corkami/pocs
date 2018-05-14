# Content of tables

- Y: yes
- W: yes, with warnings (Adobe asks to save, Firefox shows a warning)
- E: empty page only (opens but unexpectedly without any content)
- N: not working

# Whitespace

Officially:
- PDF whitespace can be 00 (NULL), 0x09 (TAB), 0x0C (Form Feed), and the return characters 0A and 0D.
- Newlines can be made of Linux standard (0A) `text` (the standard one), OS X (0D) `text-osx`, and Windows (0D 0A) `text-win`.

However:
- it's not clear where characters can be different from SPACE `20`, as adding more of them lowers the compatibility (see `ws00`, `ws00max`, `ws00max2`)
- while `0C` is official, it's not supported by Adobe.
- for unclear reasons, Chrome supports `80` and `FF` as whitespace (cf PoC||GTFO 14:10).
- newlines types can also be used together in the same file.

They can also be mixed interchangeably `text-mixedNL`.

Since XREF entries are supposedly separated by 20 characters, including newlines, then newlines of 1 character have to be pre-pended with space.

file | Adobe | Chrome | OS X | Firefox | Sumatra
:-- | :-: | :-: | :-: | :-: | :-: |
text (linux NL) | Y | Y | Y | Y | Y
text-win      | Y | Y | Y | Y | Y
text-osx      | Y | Y | Y | Y | Y
text-mixedNL  | Y | Y | Y | Y | Y
 |  |  |  |  | 
text-ws00     | W | Y | Y | Y | Y
text-ws00max  | Y | Y | N | N | N
text-ws00max2 | N | Y | N | N | N
text-ws09     | Y | Y | N | Y | Y
text-ws09max  | Y | Y | N | Y | N
text-ws0A     | Y | Y | Y | Y | Y
text-ws0C     | N | Y | N | Y | Y
text-ws0Cmax  | N | Y | N | N | N
text-ws0D     | W | Y | Y | Y | Y
 |  |  |  |  | 
text-ws80     | N | Y | N | N | N
text-wsFF     | N | Y | N | N | N

# Writing text

TODO
