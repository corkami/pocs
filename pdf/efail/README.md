PDFs with an '[EFAIL](https://efail.de/)-like' structure: being a alternated stack of 16 unknown bytes and 16 plaintext bytes.

Hex view:

```
000: 30 31 32 33 34 35 36 37 38 39 30 31 32 33 34 35  0123456789012345
010: 0A 25 50 44 46 2D 31 2E 20 25 20 20 20 20 20 20  ◙%PDF-1. %
020: 30 31 32 33 34 35 36 37 38 39 30 31 32 33 34 35  0123456789012345
030: 0A 31 20 30 20 6F 62 6A 3C 3C 20 25 20 20 20 20  ◙1 0 obj<< %
....
```

# Examples

[empty page](efail-tiny.pdf) (433 bytes)

<img width=150 src=efail-tiny.png />

[text](efail-text.pdf)

<img width=150 src=efail-text.png />

[with vector drawing](efail-vector.pdf)

<img width=150 src=efail-vector.png />
