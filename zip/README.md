# PoCs

most made by 7zip, linux ZIP or Mac, [InfoZip](ftp://ftp.info-zip.org/pub/infozip/win32/), WinRar

- `simple.zip` standard (Deflate)
 - `directory.zip` directory


small:
- `empty.zip` - just EoCD, no files (it's valid, just empty)
- `corkami.zip` - (used for the original poster) non standard, minimized (no name in Local File Header)

misc:
- `NTFS.zip` high precision time
- `NT.zip` NT ACLs
- `unicode.zip` unicode name as extra field
 - `unicode2.zip` unicode name directly as file name
- `volumecomment.zip` volume comment
 - `filecomment.zip` file comment
- `volume.zip.001`, `volume.zip.002`: volume spanning archive
- `unix.zip` Unix version
 - `unixdesc.zip` with Data Descriptor
- `zip64.zip` Zip64
- `drive.zip` the old DOS way to store the drive where files are stored
- `dual.zip` with 2 files of the same name, cf CVE-2013-4787

encryption:
- `zipcrypto.zip` old zip crypto (PkZip 2.0)
- `aes.zip` AES-256 crypto

compressions:
- `store.zip` 0-storage (no compression)
- `shrunk.zip`  1-shrunk
- `reduced1.zip` 2-reduced1
- `reduced2.zip` 3-reduced2
- `reduced3.zip` 4-reduced3
- `reduced4.zip` 5-reduced4
- `implode.zip`  6-implode
 - `implodeV3.zip`  6-implodeV3
- `simple.zip` 8-Deflate
- `deflate64.zip` 9-Deflate64
- `bz2.zip` 12-bzip2
- `lzma.zip` 14-LZMA
- `PPMd.zip` 98-PPMd
- `zopfli.zip` - super compressed with [Zopfli](https://github.com/google/zopfli) (via `advzip` from [AdvanceComp](https://www.advancemame.it/comp-readme.html))


# links

https://landave.io/2018/05/7-zip-from-uninitialized-memory-to-remote-code-execution/
