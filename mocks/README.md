# Minimal mock files

Files that fake a file type just via their magic but with no other structure
(identified but fake)


## Audio

```
00: .f .L .a .C
  flac.bin: FLAC audio bitstream data

00: .I .D .3
  id3v2.bin: Audio file with ID3 version 2

00: .M .T .h .d
  midi.bin: Standard MIDI data

00: .R .I .F .F 00 00 00 00 .W .A .V .E
  wav.bin: RIFF (little-endian) data, WAVE audio
```


## Archives

```
00: .7 .z BC AF 27 1C
  7-zip.bin: 7-zip archive data,
00: .B .Z .h
  bzip2.bin: bzip2 compressed data

00: .C .r .2 .4
  chrome.bin: Google Chrome extension

00: 1F 8B
  gzip.bin: gzip compressed data

8000:    .C .D .0 .0 .1
  iso9660.bin: ISO 9660 CD-ROM filesystem data

00: .R .E .~ .^
  rar14.bin: RAR archive data (<v1.5)
00: .R .a .r .! 1A 07 00
  rar4.bin: RAR archive data
00: .R .a .r .! 1A 07 01 00
  rar5.bin: RAR archive data, v5

100: 00 .u .s .t .a .r 00
  tar.bin: POSIX tar archive

00: .P .K 03 04
  zip.bin: Zip archive data
```


## Containers (meta-formats)

```
00: 1A .E DF A3 01
  ebml.bin: EBML file

00: .R .I .F .F
  riff.bin: RIFF (little-endian) data
00: .R .I .F .X
  rifx.bin: RIFF (big-endian) data
```


## Documents

```
00: .{ .\ .r .t .f
  rtf.bin: Rich Text Format data, unknown version

00: .% .P .D .F .- .1 ..
  pdf.bin: PDF document, version 1

00: .% .!
  postscript.bin: PostScript document text
```


## Executables

```
00: .d .e .x 0A .0 .3 .5
  dex035.bin: Dalvik dex file version 035
00: .d .e .y 0A .9 .9 .9
  dey999.bin: Dalvik dex file (optimized for host) version 999

00: 7F .E .L .F
  elf.bin: ELF

00: CA FE BA BE 01 00 00 00
  java.bin: compiled Java class data, version 0.256
00: CA FE BA BE 00 00 00 01
  univmacho.bin: Mach-O universal binary with 1 architecture: []

00: CE FA ED FE
  macho.bin: Mach-O
00: CF FA ED FE
  macho64.bin: Mach-O 64-bit

00: .M .Z
  mz.bin: MS-DOS executable
00: .M .Z
10: .P .E 00 00             40
..
30:                                     10 00 00 00
  pe.bin: PE Unknown PE signature 0x0, for MS Windows

00: 00 .a .s .m
  wasm.bin: data
```


## Images

```
80: .D .I .C .M
  dicom.bin: DICOM medical imaging data

00: .G .I .F .8
  gif8.bin: GIF image data
00: .G .I .F .8 .7 .a
  gif87a.bin: GIF image data, version 87a,
00: .G .I .F .8 .9 .a
  gif89a.bin: GIF image data, version 89a,

20:             .a .c .s .p
  icc.bin: color profile 0.0, - device, 0 bytes, PCS X=0x0 Y=0x0 Z=0x0

00: FF D8
  jpg.bin: JPEG image data

00: 89 .P .N .G 0D 0A 1A 0A
  png.bin: PNG image data

00: .I .I 42 00
  tiff2.bin: TIFF image data, little-endian
00: .M .M 00 42
  tiff1.bin: TIFF image data, big-endian

00: .< .? .x .m .l 20 .v .e .r .s .i .o .n .= ." 20
10: ." 20 20 .< .s .v .g
  svg.bin: SVG Scalable Vector Graphics image
```


## Video

```
00: .F .L .V 01
  flv.bin: Macromedia Flash Video

00: 1A .E DF A3 01 .B 82 00 .w .e .b .m
  webm.bin: WebM
00: 1A .E DF A3 01 .B 82 00 .m .a .t .r .o .s .k .a
  matroska.bin: Matroska data

00: 00 00 00 00 .f .t .y .p
  media.bin: ISO Media
```


## Misc / old

```
00:                      .* .* .A .C .E .* .*
  ace.bin: ACE archive data

00: 60 EA
  arj.bin: ARJ archive data
00: 00 00 60 EA
  arj2.bin: ARJ archive data

00:             88 F0 27
  MScompress.bin: MS Compress archive data

00: .M .Z
10: .N .E 00 00             40
..
30:                                     10 00 00 00
  ne.bin: MS-DOS executable, NE

00: .P .A .R .2
  par2.bin: Parity Archive Volume Set
```
