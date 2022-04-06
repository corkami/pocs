# Zgip: a Zip/Gzip chimera

This contains source to generate a Zip/Gzip polyglot where the deflated data is shared by both archives.

Just to prove that while Zip and Gzip can use the same compression algorithm, neither is an encapsulation of the other.


# How to

1. Generate `external.inc` by running `make.py` on any file.
   Use optionally `--skip` if you want the Gzip skip some bytes, that will be only visible in the Zip archive.

2. Use Nasm or Yasm to generate the output file from the source: `nasm zgip.asm -o <file.zip.gz>`


# Notes

As the optional Gzip filename is stored between the Extra Field and the compressed data,
and skipping content abuses the extra field to cover compressed data blocks,
the Gzip filename can't be used when skipping compressed data.
