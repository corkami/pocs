# Names

`/` is a standard name. It can be reliably used, for example for a font reference:

`empty.pdf`:

```
.../Resources<< /Font<<
/ <</Type/Font...
...
/ 55 Tf (http://www.corkami.com)'
```

# Hex escaping

## standard behavior

Names can use hexadecimal. So for example `/#41` refers to `/A` successfully - see `standard.pdf`

If there is only a `#` sign, then it's kept as is. Therefore it maps to `#23` reliably (`0x23` is `#` hex code) - see `sharp.pdf`

## non standard behavior

`-A` means supported by Adobe Reader.
Same for `C`hrome (pdfium), `S`afari (and OS X Preview), `F`irefox (pdf.js), `M`uPDF.

If there is only a single char like `#1`:

- Safari drops the extra char. so `#1` maps to `#23` - see `sharp1-S.pdf`
- Adobe, Chrome, Firefox keep the extra char: `#1` maps to `#231` - see `sharp1-ACF.pdf`

If there is an invalid character like `#1x`:
- Adobe, Firefox treat the `#` as a standard character, so it's mapped as `#23` - see `1x-AF.pdf` and `X1-ASF.pdf` (Safari allows also this case only).
- Chrome replace the characters with `0`.
  - `#1x` maps to `#10` - `1x-C.pdf`
  - `#x1` maps to `#01` - `X1-C.pdf`.

Chrome does its weird stuff with `80` and `FF` as usual. see `80-C.pdf` and `FF-C.pdf`
