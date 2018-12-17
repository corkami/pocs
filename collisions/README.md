# Introduction

This part of the repository is focused on hash collisions exploitation for MD5 and SHA1.

This is a collaboration with [Marc Stevens](https://marc-stevens.nl/research/).

The idea is to explore existing attacks, also to show how weak MD5 is (instant collisions of any JPG, PNG, PDF, MP4, PE...), and also explore file formats landscape to determine how they can be exploited with present or with future attacks:
the same file format trick can be used on several hashes, as long as the collisions follow the same byte patterns.


# Status

Current status - as of December 2018 - of known attacks:
- get a file to get another file's hash or a given hash: **impossible**
  - it's still even [not practical](https://eprint.iacr.org/2008/089.pdf) with MD2.
  - works for simpler hashes(\*) <!-- Thanks Sven! -->

- get 2 different files with the same MD5: **instant**
  - examples: [1](examples/single-ipc1.bin) & [2](examples/single-ipc2.bin)

- make 2 arbitrary files get the same MD5: **a few hours** (72 hours.core)
  - examples: [1](examples/single-cpc1.bin) & [2](examples/single-cpc2.bin)

- make 2 arbitrary files of specific file formats (PNG, JPG, PE...) get the same MD5: **instant**
  - read below

- get two different files with the same SHA1: 6500 years.core
  - get two different PDFs with the same SHA-1 to show a different picture: [instant](https://github.com/nneonneo/sha1collider) (the prefixes are already computed)


(\*) example with [crypt](https://docs.python.org/3/library/crypt.html) - thanks [Sven](https://twitter.com/svblxyz)!
```
>>> import crypt
>>> crypt.crypt("5dUD&66", "br")
'brokenOz4KxMc'
>>> crypt.crypt("O!>',%$", "br")
'brokenOz4KxMc'
```


# Attacks

MD5 and SHA1 work with blocks of 64 bytes.

If 2 contents A & B have the same hash, then appending the same contents C to both will keep the same hash.
``` text
hash(A) = hash(B) -> hash(A + C) = hash(B + C)
```


## Identical prefix

1. Define an arbitrary prefix - its content and length don't matter.
2. The prefix is padded to the next 64-byte block.
3. Collision block(s) are computed depending on the prefix and appended.
   Both sides are very random. The differences are predetermined by the attack.
4. After this[these] block[s], the hash value is the same despite the file differences.
5. Any arbitrary identical suffix can be added.

| Prefix        | = | Prefix        |
| :----:        |:-:| :----:        |
| Collision *A* | ≠ | Collision *B* |
| Suffix        | = | Suffix        |

Both files are almost identical (their content have only a few bits of differences)


### Exploitation

Bundle 2 contents, then either:
- Data exploit: run code that checks for differences and displays one or the other (typically trivial since differences are known in advance).
- Structure exploit:  exploit file structure (typically, the length of a comment) to hide one content or show the other (depends on the file format and its parsers).


Two files with this structure:

| Prefix        | = | Prefix        |
| :----:        |:-:| :----:        |
| Collision *A* | ≠ | Collision *B* |
| **A**         | = | ~~A~~         |
| ~~B~~         | = | **B**         |

will show either A or B.

<img alt='identical prefix collisions' src=pics/identical.png width=350/>


### [FastColl](https://www.win.tue.nl/hashclash/) (MD5)

- time: a few seconds of computation
- space: 2 blocks
- exploitation: hard

The differences aren't near the start/end of the blocks, so it's very hard to exploit since you don't control any nearby byte. A potential solution is to bruteforce the surrounding bytes - cf [PoCGTFO 14:10](https://github.com/angea/pocorgtfo#0x14).


#### examples

With an empty prefix:
```
00:  37 75 C1 F1-C4 A7 5A E7-9C E0 DE 7A-5B 10 80 26  7u┴±─ºZτ£α▐z[►Ç&
10:  02 AB D9 39-C9 6C 5F 02-12 C2 7F DA-CD 0D A3 B0  ☻½┘9╔l_☻↕┬⌂┌═♪ú░
20:  8C ED FA F3-E1 A3 FD B4-EF 09 E7 FB-B1 C3 99 1D  îφ·≤ßú²┤∩○τ√▒├Ö↔
30:  CD 91 C8 45-E6 6E FD 3D-C7 BB 61 52-3E F4 E0 38  ═æ╚Eµn²=╟╗aR>⌠α8

40:  49 11 85 69-EB CC 17 9C-93 4F 40 EB-33 02 AD 20  I◄àiδ╠↨£ôO@δ3☻¡
50:  A4 09 2D FB-15 FA 20 1D-D1 DB 17 CD-DD 29 59 1E  ñ○-√§· ↔╤█↨═▌)Y▲
60:  39 89 9E F6-79 46 9F E6-8B 85 C5 EF-DE 42 4F 46  9ë₧÷yFƒµïà┼∩▐BOF
70:  C2 78 75 9D-8B 65 F4 50-EA 21 C5 59-18 62 FF 7B  ┬xu¥ïe⌠PΩ!┼Y↑b {
```
- MD5: `fe6c446ee3a831ee010f33ac9c1b602c`
- SHA256: `c5dd2ef7c74cd2e80a0fd16f1dd6955c626b59def888be734219d48da6b9dbdd`


```
00:  37 75 C1 F1-C4 A7 5A E7-9C E0 DE 7A-5B 10 80 26  7u┴±─ºZτ£α▐z[►Ç&
10:  02 AB D9 B9-C9 6C 5F 02-12 C2 7F DA-CD 0D A3 B0  ☻½┘╣╔l_☻↕┬⌂┌═♪ú░
20:  8C ED FA F3-E1 A3 FD B4-EF 09 E7 FB-B1 43 9A 1D  îφ·≤ßú²┤∩○τ√▒CÜ↔
30:  CD 91 C8 45-E6 6E FD 3D-C7 BB 61 D2-3E F4 E0 38  ═æ╚Eµn²=╟╗a╥>⌠α8

40:  49 11 85 69-EB CC 17 9C-93 4F 40 EB-33 02 AD 20  I◄àiδ╠↨£ôO@δ3☻¡
50:  A4 09 2D 7B-15 FA 20 1D-D1 DB 17 CD-DD 29 59 1E  ñ○-{§· ↔╤█↨═▌)Y▲
60:  39 89 9E F6-79 46 9F E6-8B 85 C5 EF-DE C2 4E 46  9ë₧÷yFƒµïà┼∩▐┬NF
70:  C2 78 75 9D-8B 65 F4 50-EA 21 C5 D9-18 62 FF 7B  ┬xu¥ïe⌠PΩ!┼┘↑b {
```
- MD5: `fe6c446ee3a831ee010f33ac9c1b602c`
- SHA256: `e27cf3073c704d0665da42d597d4d20131013204eecb6372a5bd60aeddd5d670`

Other examples, with an identical prefix: [1](examples/fastcoll1.bin) & [2](examples/fastcoll2.bin)

Variant: there is a [single-block MD5 collision](https://marc-stevens.nl/research/md5-1block-collision/) but it takes five weeks of computation.


### [UniColl](unicoll.md) (MD5)

[UniColl](https://github.com/cr-marcstevens/hashclash#create-you-own-identical-prefix-collision) let you control a few bytes in the collision blocks, before and after the first difference, which makes it an identical-prefix collision with some controllable differences, almost like a chosen prefix collision. This is very handy, and even better the difference can be very predictable: in the case of [`m2 9`](https://github.com/cr-marcstevens/hashclash/blob/master/scripts/poc_no.sh#L30), the difference is +1 on the 9th byte, which makes it very exploitable.

- time: a few minutes (depends on the amount of byte you want to control )
- space: 2 blocks
- exploitation: very easy.

Examples with `m2 9` (`n=1` in the [script](https://github.com/cr-marcstevens/hashclash/blob/master/scripts/poc_no.sh)) with 20 bytes of set text in the hash:
```
00:  55 6E 69 43-6F 6C 6C 20-31 20 70 72-65 66 69 78  UniColl 1 prefix
10:  20 32 30 62-F5 48 34 B9-3B 1C 01 9F-C8 6B E6 44   20b⌡H4╣;∟☺ƒ╚kµD
20:  FE F6 31 3A-63 DB 99 3E-77 4D C7 5A-6E B0 A6 88  ■÷1:c█Ö>wM╟Zn░ªê
30:  04 05 FB 39-33 21 64 BF-0D A4 FE E2-A6 9D 83 36  ♦♣√93!d┐♪ñ■Γª¥â6
40:  4B 14 D7 F2-47 53 84 BA-12 2D 4F BB-83 78 6C 70  K¶╫≥GSä║↕-O╗âxlp
50:  C6 EB 21 F2-F6 59 9A 85-14 73 04 DD-57 5F 40 3C  ╞δ!≥÷YÜà¶s♦▌W_@<
60:  E1 3F B0 DB-E8 B4 AA B0-D5 56 22 AF-B9 04 26 FC  ß?░█Φ┤¬░╒V"»╣♦&ⁿ
70:  9F D2 0C 00-86 C8 ED DE-85 7F 03 7B-05 28 D7 0F  ƒ╥♀ å╚φ▐à⌂♥{♣(╫☼
```

```
00:  55 6E 69 43-6F 6C 6C 20-31 21 70 72-65 66 69 78  UniColl 1!prefix
10:  20 32 30 62-F5 48 34 B9-3B 1C 01 9F-C8 6B E6 44   20b⌡H4╣;∟☺ƒ╚kµD
20:  FE F6 31 3A-63 DB 99 3E-77 4D C7 5A-6E B0 A6 88  ■÷1:c█Ö>wM╟Zn░ªê
30:  04 05 FB 39-33 21 64 BF-0D A4 FE E2-A6 9D 83 36  ♦♣√93!d┐♪ñ■Γª¥â6
40:  4B 14 D7 F2-47 53 84 BA-12 2C 4F BB-83 78 6C 70  K¶╫≥GSä║↕,O╗âxlp
50:  C6 EB 21 F2-F6 59 9A 85-14 73 04 DD-57 5F 40 3C  ╞δ!≥÷YÜà¶s♦▌W_@<
60:  E1 3F B0 DB-E8 B4 AA B0-D5 56 22 AF-B9 04 26 FC  ß?░█Φ┤¬░╒V"»╣♦&ⁿ
70:  9F D2 0C 00-86 C8 ED DE-85 7F 03 7B-05 28 D7 0F  ƒ╥♀ å╚φ▐à⌂♥{♣(╫☼
```

UniColl has less control than chosen prefix, but it's much faster especially since it takes only 2 blocks.

It was used in the [Google CTF 2018](https://github.com/google/google-ctf/tree/master/2018/finals/crypto-hrefin), where the frequency of a certificate serial changes and limitations on the lengths prevented the use of chosen prefix collisions.


### [Shattered](http://shattered.io) (SHA1)

It was computed only once to our knowledge.

- time: 6500 years.CPU and 110 year.GPU
- space: 2 blocks
- exploitation: easy. The differences are right at the start of the collision blocks.

Examples: [PoC||GTFO 0x18](https://github.com/angea/pocorgtfo#0x18)


## Chosen-prefix collisions

They allow to collide any content. They don't exist for SHA-1 yet.

| 𝓐            | ≠ | 𝔅             |
| :----:        |:-:| :----:        |
| Collision *A* | ≠ | Collision *B* |

1. take 2 arbitrary prefixes
2. pad the shortest to be as long as the longest. both are padded to the next block - minus 12 bytes
  - these 12 bytes of random data will be added on both sides to randomize the birthday search
3. X near-collision blocks will be computed and appended.
   
   The fewer blocks, the longer the computation.

   Ex: [400 kHours for 1 block](https://www.win.tue.nl/hashclash/SingleBlock/). 72 hours.cores for 9 blocks with [HashClash](https://github.com/cr-marcstevens/hashclash).

<img alt='chosen-prefix collisions' src=pics/chosen.png width=400/>

Chosen prefix collisions are almighty, but they can take a long time just for a pair of files.


### [HashClash](https://github.com/cr-marcstevens/hashclash) (MD5)


Examples: let's collide `yes` and `no`. It took 3 hours on 24 cores.

`yes`:
```
000:  79 65 73 0A-3D 62 84 11-01 75 D3 4D-EB 80 93 DE  yes◙=bä◄☺u╙MδÇô▐
010:  31 C1 D9 30-45 FB BE 1E-71 F0 0A 63-75 A8 30 AA  1┴┘0E√╛▲q≡◙cu¿0¬
020:  98 17 CA E3-A2 6B 8E 3D-44 A9 8F F2-0E 67 96 48  ÿ↨╩πókÄ=D⌐Å≥♫gûH
030:  97 25 A6 FB-00 00 00 00-49 08 09 33-F0 62 C4 E8  ù%ª√    I◘○3≡b─Φ

040:  D5 F1 54 CD-CA A1 42 90-7F 9D 3D 9A-67 C4 1B 0F  ╒±T═╩íBÉ⌂¥=Üg─←☼
050:  04 9F 19 E8-92 C3 AA 19-43 31 1A DB-DA 96 01 54  ♦ƒ↓ΦÆ├¬↓C1→█┌û☺T
060:  85 B5 9A 88-D8 A5 0E FB-CD 66 9A DA-4F 20 8A AA  à╡Üê╪Ñ♫√═fÜ┌O è¬
070:  BA E3 9C F0-78 31 8F D1-14 5F 3E B9-0F 9F 3E 19  ║π£≡x1Å╤¶_>╣☼ƒ>↓

080:  09 9C BB A9-45 89 BA A8-03 E6 C0 31-A0 54 D6 26  ○£╗⌐Eë║¿♥µ└1áT╓&
090:  3F 80 4C 06-0F C7 D9 19-09 D3 DA 14-FD CB 39 84  ?ÇL♠☼╟┘↓○╙┌¶²╦9ä
0A0:  1F 0D 77 5F-55 AA 7A 07-4C 24 8B 13-0A 54 A2 BC  ▼♪w_U¬z•L$ï‼◙Tó╝
0B0:  C5 12 7D 4F-E0 5E F2 23-C5 07 61 E4-80 91 B2 13  ┼↕}Oα^≥#┼•aΣÇæ▓‼

0C0:  E7 79 07 2A-CF 1B 66 39-8C F0 8E 7E-75 25 22 1D  τy•*╧←f9î≡Ä~u%"↔
0D0:  A7 3B 49 4A-32 A4 3A 07-61 26 64 EA-6B 83 A2 8D  º;IJ2ñ:•a&dΩkâóì
0E0:  BE A3 FF BE-4E 71 AE 18-E2 D0 86 4F-20 00 30 26  ╛ú ╛Nq«↑Γ╨åO  0&
0F0:  0A 71 DE 1F-40 B4 F4 8F-9C 50 5C 78-DD CD 72 89  ◙q▐▼@┤⌠Å£P\x▌═rë

100:  BA D1 BF F9-96 80 E3 06-96 F3 B9 7C-77 2D EB 25  ║╤┐∙ûÇπ♠û≤╣|w-δ%
110:  1E 56 70 D7-14 1F 55 4D-EC 11 58 59-92 45 E1 33  ▲Vp╫¶▼UM∞◄XYÆEß3
120:  3E 0E A1 6E-FF D9 90 AD-F6 A0 AD 0E-C6 D6 88 12  >♫ín ┘É¡÷á¡♫╞╓ê↕
130:  B8 74 F2 9E-DD 53 F7 88-19 73 85 39-AA 9B E0 8D  ╕t≥₧▌S≈ê↓sà9¬¢αì

140:  82 BF 9C 5E-58 42 1E 3B-94 CF 5B 54-73 5F A8 4A  é┐£^XB▲;ö╧[Ts_¿J
150:  FD 5B 64 CF-59 D1 96 74-14 B3 0C AF-11 1C F9 47  ²[d╧Y╤ût¶│♀»◄∟∙G
160:  C5 7A 2C F7-D5 24 F5 EB-BE 54 3E 12-B0 24 67 3F  ┼z,≈╒$⌡δ╛T>↕░$g?
170:  01 DD 95 76-8D 0D 58 FB-50 23 70 3A-BD ED BE AC  ☺▌òvì♪X√P#p:╜φ╛¼

180:  B8 32 DB AE-E8 DC 3A 83-7A C8 D5 0F-08 90 1D 99  ╕2█«Φ▄:âz╚╒☼◘É↔Ö
190:  2D 7D 17 34-4E A8 21 98-61 1A 65 DA-FC 9B A4 BA  -}↨4N¿!ÿa→e┌ⁿ¢ñ║
1A0:  E1 42 2B 86-0C 94 2A F6-D6 A4 81 B5-2B 0B E9 37  ßB+å♀ö*÷╓ñü╡+♂Θ7
1B0:  44 D2 E4 23-14 7C 16 B8-84 90 8B E0-A1 A7 BD 27  D╥Σ#¶|▬╕äÉïαíº╜'

1C0:  C7 7E E6 17-1A 93 C5 EE-59 70 91 26-4E 9D C7 7C  ╟~µ↨→ô┼εYpæ&N¥╟|
1D0:  1D 3D AB F1-B4 F4 F1 D9-86 48 75 77-6E FE 98 84  ↔=½±┤⌠±┘åHuwn■ÿä
1E0:  EF 3C 1C C7-16 5A 1F 83-60 EC 5C FE-CA 17 0C 74  ∩<∟╟▬Z▼â`∞\■╩↨♀t
1F0:  EB 8E 9D F6-90 A3 CD 08-65 D5 5A 4C-2E C6 BE 54  δÄ¥÷Éú═◘e╒ZL.╞╛T
```

`no`:
```
000:  6E 6F 0A E5-5F D0 83 01-9B 4D 55 06-61 AB 88 11  no◙σ_╨â☺¢MU♠a½ê◄
010:  8A FA 4D 34-B3 75 59 46-56 97 EF 6C-4A 07 90 CC  è·M4│uYFVù∩lJ•É╠
020:  FE 19 D7 CF-6F 92 03 9C-91 AA A5 DA-56 92 C1 04  ■↓╫╧oÆ♥£æ¬Ñ┌VÆ┴♦
030:  E6 4C 08 A3-00 00 00 00-8D B6 4E 47-FF AF 7A 3C  µL◘ú    ì╢NG »z<

040:  D5 F1 54 CD-CA A1 42 90-7F 9D 3D 9A-67 C4 1B 0F  ╒±T═╩íBÉ⌂¥=Üg─←☼
050:  04 9F 19 E8-92 C3 AA 19-43 31 1A DB-DA 96 01 54  ♦ƒ↓ΦÆ├¬↓C1→█┌û☺T
060:  85 B5 9A 88-D8 A5 0E FB-CD 66 9A DA-4F 20 8A A9  à╡Üê╪Ñ♫√═fÜ┌O è⌐
070:  BA E3 9C F0-78 31 8F D1-14 5F 3E B9-0F 9F 3E 19  ║π£≡x1Å╤¶_>╣☼ƒ>↓

080:  09 9C BB A9-45 89 BA A8-03 E6 C0 31-A0 54 D6 26  ○£╗⌐Eë║¿♥µ└1áT╓&
090:  3F 80 4C 06-0F C7 D9 19-09 D3 DA 14-FD CB 39 84  ?ÇL♠☼╟┘↓○╙┌¶²╦9ä
0A0:  1F 0D 77 5F-55 AA 7A 07-4C 24 8B 13-0A 54 B2 BC  ▼♪w_U¬z•L$ï‼◙T▓╝
0B0:  C5 12 7D 4F-E0 5E F2 23-C5 07 61 E4-80 91 B2 13  ┼↕}Oα^≥#┼•aΣÇæ▓‼

0C0:  E7 79 07 2A-CF 1B 66 39-8C F0 8E 7E-75 25 22 1D  τy•*╧←f9î≡Ä~u%"↔
0D0:  A7 3B 49 4A-32 A4 3A 07-61 26 64 EA-6B 83 A2 8D  º;IJ2ñ:•a&dΩkâóì
0E0:  BE A3 FF BE-4E 71 AE 18-E2 D0 86 4F-20 00 30 22  ╛ú ╛Nq«↑Γ╨åO  0"
0F0:  0A 71 DE 1F-40 B4 F4 8F-9C 50 5C 78-DD CD 72 89  ◙q▐▼@┤⌠Å£P\x▌═rë

100:  BA D1 BF F9-96 80 E3 06-96 F3 B9 7C-77 2D EB 25  ║╤┐∙ûÇπ♠û≤╣|w-δ%
110:  1E 56 70 D7-14 1F 55 4D-EC 11 58 59-92 45 E1 33  ▲Vp╫¶▼UM∞◄XYÆEß3
120:  3E 0E A1 6E-FF D9 90 AD-F6 A0 AD 0E-CA D6 88 12  >♫ín ┘É¡÷á¡♫╩╓ê↕
130:  B8 74 F2 9E-DD 53 F7 88-19 73 85 39-AA 9B E0 8D  ╕t≥₧▌S≈ê↓sà9¬¢αì

140:  82 BF 9C 5E-58 42 1E 3B-94 CF 5B 54-73 5F A8 4A  é┐£^XB▲;ö╧[Ts_¿J
150:  FD 5B 64 CF-59 D1 96 74-14 B3 0C AF-11 1C F9 47  ²[d╧Y╤ût¶│♀»◄∟∙G
160:  C5 7A 2C F7-D5 24 F5 EB-BE 54 3E 12-70 24 67 3F  ┼z,≈╒$⌡δ╛T>↕p$g?
170:  01 DD 95 76-8D 0D 58 FB-50 23 70 3A-BD ED BE AC  ☺▌òvì♪X√P#p:╜φ╛¼

180:  B8 32 DB AE-E8 DC 3A 83-7A C8 D5 0F-08 90 1D 99  ╕2█«Φ▄:âz╚╒☼◘É↔Ö
190:  2D 7D 17 34-4E A8 21 98-61 1A 65 DA-FC 9B A4 BA  -}↨4N¿!ÿa→e┌ⁿ¢ñ║
1A0:  E1 42 2B 86-0C 94 2A F6-D6 A4 81 B5-2B 2B E9 37  ßB+å♀ö*÷╓ñü╡++Θ7
1B0:  44 D2 E4 23-14 7C 16 B8-84 90 8B E0-A1 A7 BD 27  D╥Σ#¶|▬╕äÉïαíº╜'

1C0:  C7 7E E6 17-1A 93 C5 EE-59 70 91 26-4E 9D C7 7C  ╟~µ↨→ô┼εYpæ&N¥╟|
1D0:  1D 3D AB F1-B4 F4 F1 D9-86 48 75 77-6E FE 98 84  ↔=½±┤⌠±┘åHuwn■ÿä
1E0:  EF 3C 1C C7-16 5A 1F 83-60 EC 5C FE-CA 17 0C 54  ∩<∟╟▬Z▼â`∞\■╩↨♀T
1F0:  EB 8E 9D F6-90 A3 CD 08-65 D5 5A 4C-2E C6 BE 54  δÄ¥÷Éú═◘e╒ZL.╞╛T
```


# Exploitations

Identical prefix collisions is usually seen as (very) limited, but chosen prefix is time consuming.

Another approach is to craft re-usable prefixes via either identical-prefix attack such as UniColl - or chosen prefix to overcome some limitations - but re-use that prefix pair in combinations with 2 payloads like a classic identical prefix attack.

Once the prefix pair has been computed, it makes colliding 2 contents instant:
it's just a matter of massaging file data (according to specific file formats) so that it fits the file formats specifications and the pre-computed prefix requirements.


## standard collisions

Classic collisions of 2 valid files with the same filetype.


### JPG

Theoretical limitations and workarounds:
- the *Application* segment should in theory right after the *Start of Image* marker. In practice, this is not necessary, so our collision can be generic: the only limitation is the size of the smallest image.
- a comment's length is stored on 2 bytes, so it's limited to 65536 bytes. To jump over another image, its *Entropy Coded Segment* needs to be split to scans smaller than this, either by storing the image as progressive, either by using *JPEGTran* and custom scans definition.

So an MD5 collision of 2 arbitrary JPGs is *instant*, and needs no chosen-prefix collision, just UniColl.

With the [script](scripts/jpg.py):
```
21:07:35.65>jpg.py Ange.jpg Marc.jpg

21:07:35.75>
```

<img alt='identical prefix collisions' src=examples/collision1.jpg height=250/>
<img alt='identical prefix collisions' src=examples/collision2.jpg height=250/>


### PNG

Theoretical limitations and workarounds:
- PNG uses CRC32 at the end of its chunks, which would prevent the use of collision blocks, but in practice they're ignored.
- the image metadata (dimensions, colorspace...) are stored in the `IHDR` chunk, which should in theory be right after the signature (ie, before any potential comment), so it would mean that we can only pre-compute collisions of images with the same metadata. However, that chunk can actually be after a comment block, so we can put the collision data before the header, which enables to collide any pair of PNG with a single pre-computation. 

Since a PNG chunk has a length on 4 bytes, there's no need to modify the structure of either file: we can jump over a whole image in one go.

We can insert as many discarded chunks as we want, so we can add one for alignment, then one which length will be altered by a UniColl. so the length will be `00` `75` and `01` `75`.

So an MD5 collision of 2 arbitrary PNG images is *instant*, with no pre-requesite (no computation, just some minor file changes), and needs no chosen-prefix collision, just UniColl.

With the [script](scripts/png.py):
```
19:27:04.79>png.py nintendo.png sega.png

19:27:04.87>
```

<img alt='identical prefix collisions' src=examples/collision1.png width=350/>
<img alt='identical prefix collisions' src=examples/collision2.png width=350/>


### GIF

GIF is tricky:
- it stores its metadata in the header before any comment is possible, so there can't be a generic prefix for all GIF files.
 - if the file has a global palette, it is also stored before a comment is possible too.
- its comment chunks are limited to a single byte in length, so a maximum of 256 bytes!

However, the comment chunks follow a peculiar structure: it's a chain of `<length:1>` `<data:length>` until a null length is defined. So it makes any non-null byte a valid 'jump forward'. Which makes it suitable to be used with FastColl, as 
shown in [PoC||GTFO 14:11](https://github.com/angea/pocorgtfo#0x14). 

So at least, even if we can't have a generic prefix, we can collide any pair of GIF of same metadata (dimensions, palette) and we only need a second of FastColl to compute its prefix.

Now the problem is that we can't jump over a whole image like PNG or over a big structure like JPG.

A possible workaround is to massage the compressed data or to chunk the image in tiny areas like in the case of the GIF Hashquine, but this is not optimal.

Another idea that works generically is that the image data is also stored using this `length data` sequence structure:
so if we take 2 GIFs with no animation, we only have to:
- normalize the palette
- set the first frame duration to the maximum
- craft a comment that will jump to the start of the first frame data, so that the comment will sled over the image data as a comment, and end the same way: until a null length is encountered. Then the parser will meet the next frame, and display it. 

With a minor setup (only a few hundred bytes of overhead), we can sled over any GIF image and work around the 256 bytes limitation. This idea was suggested by Marc, and it's brilliant!


So in the end, the current GIF limitations for *instant* MD5 collisions are:
- no animation
- the images have to be normalized to the same palette - see [Gifsicle](https://www.lcdf.org/gifsicle/)
- the images have to be the same dimensions
- after 11 minutes, both files will show the same image

<img alt='identical prefix collisions' src=examples/collision1.gif width=350/>
<img alt='identical prefix collisions' src=examples/collision2.gif width=350/>

*Pics by [KidMoGraph](https://www.kidmograph.com/)*


### Portable Executable

The Portable Executable has a peculiar structure:
- the old DOS header is almost useless, and points to the next structure, the PE header. The DOS headers has no other role. DOS headers can be exchanged between executables.
- The PE header and what follows defines the whole file. 

So the strategy is:
1. the PE header can be moved down to leave room for collision blocks after the DOS header.
2. The DOS header can be exploited (via chosen prefix collisions) to point to 2 different offsets, where 2 different PE headers will be moved.
3. The sections can be put next to each other, after the `DOS/Collisions/Header1/Header2` structure. You just need to apply a delta to the offsets of the 2 section tables.

This means that it's possible to instantly collide any pair of PE executables. Even if they use different subsystems or architecture.

While executables collisions is usually trivial via any loader, this kind of exploitation here is transparent: the code is identical and loaded at the same address.

Examples: [tweakPNG.exe](examples/collision1.exe) (GUI) & [fastcoll.exe](examples/collision2.exe) (CLI)


## MP4

The format is quite permissive. Just use `free` atoms, abuse a length with UniColl, then jump over the first video.

The only thing to know is to adjust the `stco` or `co64` tables, since they are absolute(!) offsets pointing to the `mdat` movie data and they are enforced.

Examples: [collision1.mp4](examples/collision1.mp4) & [collision2.mp4](examples/collision2.mp4)

*Videos by [KidMoGraph](https://www.kidmograph.com/)*

This should be extendable to any MP4-like format (in terms of Atom/Box structures), such as HEIF or JP2.


## PDF

PDF can store foreign data in two ways: 
- as a line comment, in which the only forbidden characters are new lines. This can be used inside a dictionary object, to modify for example an object reference, via UniColl.
- as a stream object, in which case any data is possible, but since we're inside an object, we can't alter the whole PDF structure, so it requires a chosen prefix collision.

The first case enables to highlight the beauty of UniColl, a collision where differences are predictable, so you can write poetry over colliding data!

[poeMD5 A](examples/poeMD5_A.pdf)
```
         V
Now he hash MD5,
No enemy cares!
 Only he gave
 the shards.
Can’t be owned &
his true gold,
like One Frail,
sound as fold.
         ^
```

[poeMD5 B](examples/poeMD5_B.pdf)
```
         V
Now he hath MD5,
No enemy dares!
 Only he have
 the shares.
Can’t be pwned &
his true hold,
like One Grail,
sound as gold.
         ^
```

(Note I screwed up with Adobe compatibility, but that's my fault, not UniColl's)

Of course another use is that you alter the Root object, which enables to instantly collide any arbitrary pair of PDF.

A useful trick is that `mutool clean` output is reliably predictable, so it can be used to normalize PDFs as input, and fix your merged PDF while keeping the important parts of the file unmodified.

Examples: [spectre.pdf](examples/collision1.pdf) & [meltdown.pdf](examples/collision2.pdf)

<img alt='identical prefix PDF collisions' src=pics/specdown.png width=500/>


### Unicoll based


## Uncommon collisions

Collisions are usually about 2 valid files of the same type.

### MultiColls: multiple collisions chain
Nothing prevents to chain several collision blocks, and have more than 2 contents with the same hash value. An example of that are Hashquines - that shows their own MD5 value. The [PoCGTFO 14](https://github.com/angea/pocorgtfo#0x14) file contains 609 FastColl collisions, to do that through 2 file types in the same file.


### Validity

A different strategy would be to kill the file type to bypass scanning as a corrupted file. Just overwriting the magic signature will be enough. Appending both files (as valid or invalid) with a format that doesn't need to be at offset 0 (archive, like ZIP/RAR/...) would reveal another file type.

This enables polyglot collisions without using a Chosen prefix collision:
1. use UniColl to enable or disable a magic signature, for example a PNG:
2. append a ZIP archive

While technically both files are a valid ZIP, since most parser return the first file type found and they start scanning at offset 0, they will see a different file type.

Examples: ![valid](examples/png-valid.png) - [invalid](examples/png-invalid.png)


### Gotta collide 'em all!

Another use of instant, re-usable and generic collisions would be to hide any file of a given type - say PNG - behind dummy files (or the same file every time) - which is actually just by concatenating it to the same prefix after stripping the signature - you could even do that at library level!

From a strict parsing perspective,
all your files will show the same content,
and the evil images would be revealed as a file with the same MD5 as previously collected.

Let's take 2 files:

<img alt='MS 08-067' src=pics/trinity.png width=300/> and 
<img alt='MS 08-067' src=pics/javascript.png width=300/>

and collide them with the same PNG.

They now show the same dummy image, and they're absolutely identical until the 2nd image at file level!

<img alt='MS 08-067' src=examples/gcea1.png width=200/> and 
<img alt='MS 08-067' src=examples/gcea2.png width=200/>

Their evil payload is hidden behind a file with the same MD5 respectively:
don't collect evidences by MD5 without any file introspection.
So better discard MD5 altogether, because file introspection is just too time-consuming and too risky!


### PolyColls: collisions of different file types

It's also possible to have both side of a collision with different types to lower suspicion:

Attack scenario:
1. send `holiday.jpg`
2. get it whitelisted
3. send `evil.exe`, which has the same MD5.

Some examples of polycoll layouts:

![pdf-jpg polyglot collision](pics/pdf-jpg.png)

*PDF/JPG polycoll*


![pe-png polyglot collision](pics/pe-png.png)

*PE/PNG polycoll*


### Portable Executable - JPG

Since a PE header is usually smaller than 0x500 bytes, it's a perfect fit for a JPG comment:
1. start with DOS/JPG headers
2. JPEG-comment jumps over PE Header
3. Put the full JPG image
4. Put the whole PE specifications

Once again, the collision is instant.

Examples: [fastcoll.exe](examples/jpg-pe.exe) & [Marc.jpg](examples/jpg-pe.jpg) 


### PDF - PNG

Similarly, it's possible to collide for example arbitrary PDF and PNG files with no restriction on either side. This is instant, re-usable and generic.

Examples: [Hello.pdf](examples/png-pdf.pdf) & [1x1.png](examples/png-pdf.png)


# Presentations

- Exploiting Hash Collisions (2017): [slides](https://speakerdeck.com/ange/exploiting-hash-collisions)

  [![Exploiting hash collisions youtube video](https://img.youtube.com/vi/Y-oJWEYKVLA/0.jpg)](https://www.youtube.com/watch?v=Y-oJWEYKVLA)


# Conclusion

**Kill MD5**:
unless you actively check for malformations or collisions blocks in files, don't use MD5:
it's not a cryptographic hash, it's a toy function!
