# Polymocks

Polymocks are files pretending to be polyglots but are actually invalid.

## multi

Output of `file --keep-going`:

```
multi: Windows Program Information File for \030(o\001
- MAR Area Detector Image,
- Linux kernel x86 boot executable RW-rootFS,
- ReiserFS V3.6
- Files-11 On-Disk Structure (ODS-52); volume label is '            '
- DOS/MBR boot sector
- Game Boy ROM image (Rev.00) [ROM ONLY], ROM: 256Kbit
- Plot84 plotting file
-  DOS/MBR boot sector
- DOSFONT2 encrypted font data
- Kodak Photo CD image pack file , landscape mode
- SymbOS executable v., name: HNRO0\334\247\304\375]\034\236\243
- ISO 9660 CD-ROM filesystem data (raw 2352 byte sectors)
- High Sierra CD-ROM filesystem data
- Nero CD image at 0x4B000 ISO 9660 CD-ROM filesystem data
- Old EZD Electron Density Map
- Apple File System (APFS), blocksize 24061976
- Zoo archive data, modify: v78.88+
- Symbian installation file
- 4-channel Fasttracker module sound data Title: "MZ`\352\210\360'\315!"
- Scream Tracker Sample adlib drum mono 8bit unpacked
- Poly Tracker PTM Module Title: "MZ`\352\210\360'\315!"
- SNDH Atari ST music
- SoundFX Module sound file
- D64 Image
- Nintendo Wii disc image: "NXSB\030(o\001" (MZ`\35, Rev.205)
- Nintendo 3DS File Archive (CFA) (v0, 0.0.0)
- Unix Fast File system [v1] (little-endian), last mounted on , last written at Thu Jan 01 00:00:00 1970, clean flag 0, number of blocks 0, number of data blocks 0, number of cylinder groups 0, block size 0, fragment size 0, minimum percentage of free blocks 0, rotational delay 0ms, disk rotational speed 0rps, TIME optimization
- Unix Fast File system [v2] (little-endian) last mounted on , last written at Thu Jan 01 01:00:00 1970, clean flag 0, readonly flag 0, number of blocks 0, number of data blocks 0, number of cylinder groups 0, block size 0, fragment size 0, average file size 0, average number of files in dir 0, pending blocks to free 0, pending inodes to free 0, system-wide uuid 0, minimum percentage of free blocks 0, TIME optimization
- Unix Fast File system [v2] (little-endian) last mounted on , last written at Thu Jan 01 01:00:00 1970, clean flag 0, readonly flag 0, number of blocks 0, number of data blocks 0, number of cylinder groups 0, block size 0, fragment size 1934189906, average file size 0, average number of files in dir 0, pending blocks to free 0, pending inodes to free 0, system-wide uuid 0, minimum percentage of free blocks 115, TIME optimization
- F2FS filesystem, UUID=00000000-0000-0000-0000-000000000000, volume name ""
- ISO 9660 CD-ROM filesystem data (DOS/MBR boot sector)
- DICOM medical imaging data
- Linux kernel ARM boot executable zImage (little-endian)
- CCP4 Electron Density Map
- Ultrix core file from 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
- VirtualBox Disk Image (MZ`\352\210\360'\315!), 5715999566798081280 bytes
- MS Compress archive data
- AMUSIC Adlib Tracker
-  MS-DOS executable, MZ for MS-DOS
-  COM executable for DOS
- JPEG 2000 image
- ARJ archive data
- unicos (cray) executable
- IBM OS/400 save file data
-  (Lepton 3.x), scale 0-0, spot sensor temperature 0.000000, unit celsius, color scheme 0, calibration: offset 0.000000, slope 0.000000
-  (Lepton 2.x), scale 0-0, spot sensor temperature 0.000000, unit celsius, color scheme 0, calibration: offset 0.000000, slope 0.000000
- data
```

Output of `binwalk`:

```
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Gameboy ROM,, [ROM ONLY], ROM: 256Kbit
80            0x50            RAR archive data, version 5.x
88            0x58            lrzip compressed data
89            0x59            rzip compressed data - version 76.79 (1411720504 bytes)
114           0x72            xz compressed data
120           0x78            LZ4 compressed data
132           0x84            PDF document, version: "1.4 obj stream endstream endobj xref trailer startxref"
385           0x181           LZ4 compressed data, legacy
339984        0x53010         Xerox DLM firmware name: ""
340016        0x53030         Xerox DLM firmware version: ""
340048        0x53050         Xerox DLM firmware start of header
340064        0x53060         Xerox DLM firmware end of header
340096        0x53080         PGP armored data,
340144        0x530B0         PEM certificate request
340176        0x530D0         PEM DSA private key
340208        0x530F0         PEM EC private key
340240        0x53110         PEM RSA private key
340336        0x53170         GPG key trust database version 0
340416        0x531C0         mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
340464        0x531F0         LZO compressed data
340480        0x53200         LZO compressed data
340496        0x53210         JAM archive
340512        0x53220         CRC32 polynomial table, big endian
340544        0x53240         CRC32 polynomial table, little endian
340576        0x53260         DES SP1, little endian
340624        0x53290         DES SP1, big endian
340672        0x532C0         DES SP2, little endian
340720        0x532F0         DES SP2, big endian
340768        0x53320         DES PC1 table
340832        0x53360         DES PC2 table
340928        0x533C0         YAFFS filesystem, little endian
340944        0x533D0         Pcap-ng capture file, big-endian, version 0.0
340960        0x533E0         Pcap-ng capture file, little-endian, version 0.0
340976        0x533F0         Amino MCastFS2 (.mcfs)
340992        0x53400         gzip compressed data, from FAT filesystem (MS-DOS, OS/2, NT), last modified: 1970-01-01 00:00:00 (null date)
341040        0x53430         Windows Script Encoded Data (screnc.exe)
341104        0x53470         Marvell Libertas firmware
341168        0x534B0         HTML document footer
341184        0x534C0         XML document, version: ""
341200        0x534D0         SHA256 hash constants, big endian
341232        0x534F0         SHA256 hash constants, little endian
341328        0x53550         KGB archive
341360        0x53570         Toshiba EFI capsule, header size: 0, flags: 0x00000000, capsule size: 0
341392        0x53590         QNX6 Super Block
342320        0x53930         AMI Aptio extended EFI capsule, header size: 0, flags: 0x00000000, capsule size: 0
342352        0x53950         AMI Aptio unsigned EFI capsule, header size: 0, flags: 0x00000000, capsule size: 0
342400        0x53980         HP LaserJet 1000 series downloadable firmware
342416        0x53990         Compiled Java class data, version 0.0
342432        0x539A0         EFI capsule v0.9, header size: 0, flags: 0x00000000, capsule size: 0
342464        0x539C0         UEFI capsule, header size: 0, flags: 0x00000000, capsule size: 0
342528        0x53A00         Mach-O universal binary with 1 architecture
342544        0x53A10         Mach-O universal binary with 2 architectures
342560        0x53A20         Mach-O universal binary with 3 architectures
342576        0x53A30         Mach-O universal binary with 4 architectures
342592        0x53A40         Mach-O universal binary with 5 architectures
342608        0x53A50         Mach-O universal binary with 6 architectures
342624        0x53A60         Mach-O universal binary with 7 architectures
342640        0x53A70         Mach-O universal binary with 8 architectures
342656        0x53A80         Mach-O universal binary with 9 architectures
342672        0x53A90         Mach-O universal binary with 10 architectures
342688        0x53AA0         Mach-O universal binary with 11 architectures
342704        0x53AB0         Mach-O universal binary with 12 architectures
342720        0x53AC0         Mach-O universal binary with 13 architectures
342736        0x53AD0         Mach-O universal binary with 14 architectures
342752        0x53AE0         Mach-O universal binary with 15 architectures
342768        0x53AF0         Mach-O universal binary with 16 architectures
342784        0x53B00         Mach-O universal binary with 17 architectures
342800        0x53B10         Mach-O universal binary with 18 architectures
342816        0x53B20         QNX4 Boot Block
342848        0x53B40         xz compressed data
342928        0x53B90         Snappy compression, stream identifier
342944        0x53BA0         Motorola UTAGS, size: 1414746705, flags: 58575655, crc32: 62615a59
342960        0x53BB0         Base64 standard index table
343040        0x53C00         Base64 SerComm index table
343136        0x53C60         Thompson/Alcatel encoded firmware, version: 65.78.68.82, size: 0, crc: 0x414E4452, try decryption tool from: http://web.archive.org/web/20130929103301/http://download.modem-help.co.uk/mfcs-A/Alcatel/Modems/Misc/
343168        0x53C80         Android bootimg, kernel size: 0 bytes, kernel addr: 0x0, ramdisk size: 1380208193 bytes, ramdisk addr: 0x2044494F, product name: "B000FF"
343216        0x53CB0         Windows CE image header, image start: 0x0, image length: 0
343248        0x53CD0         Broadcom header, number of sections: 0,
343328        0x53D20         Mediatek bootloader
343344        0x53D30         BORG Backup Archive
343408        0x53D70         bzip2 compressed data, block size = 100k
343424        0x53D80         bzip2 compressed data, block size = 200k
343440        0x53D90         bzip2 compressed data, block size = 300k
343456        0x53DA0         bzip2 compressed data, block size = 400k
343472        0x53DB0         bzip2 compressed data, block size = 500k
343488        0x53DC0         bzip2 compressed data, block size = 600k
343504        0x53DD0         bzip2 compressed data, block size = 700k
343520        0x53DE0         bzip2 compressed data, block size = 800k
343536        0x53DF0         bzip2 compressed data, block size = 900k
343616        0x53E40         VMWare3 undoable disk image, "CRfs"
343632        0x53E50         VMWare3 disk image, (760369987/846554724/0)
343648        0x53E60         COBALT boot rom data (Flat boot rom or file system)
343664        0x53E70         CSR (XAP2) DFU firmware update header
343696        0x53E90         CSYS header, little endian, size: 0
343712        0x53EA0         CSYS header, big endian, size: 0
343728        0x53EB0         BitTorrent file
343760        0x53ED0         OpenSSH ECDSA (Curve P-256) public key
343792        0x53EF0         OpenSSH ECDSA (Curve P-384) public key
343824        0x53F10         OpenSSH ECDSA (Curve P-521) public key
343856        0x53F30         OpenSSH DSA public key
343872        0x53F40         OpenSSH RSA public key
343968        0x53FA0         eCos RTOS string reference: "ecos"
343984        0x53FB0         eCos RTOS string reference: "ECOS"
344000        0x53FC0         eCos RTOS string reference: "eCos"
344016        0x53FD0         LANCOM firmware loader, model: "", loader version: "SC",
344032        0x53FE0         LANCOM WWAN firmware
344048        0x53FF0         LANCOM firmware header, model: "", firmware version: "SO", dev build 76 ("")
344064        0x54000         LANCOM OEM file
344112        0x54030         EST flat binary
344192        0x54080         Realtek firmware header, ROME bootloader, header version: 0, created: 0/0/0, image size: 1195724627 bytes, body checksum: 0x0, header checksum: 0x0
344224        0x540A0         GIF image data
344240        0x540B0         GNU tar incremental snapshot data, version: "GNU tar-"
344272        0x540D0         HPACK archive data
344416        0x54160         QNAP encrypted firmware footer , model:  , version:
344432        0x54170         Toshiba SSD Firmware Update
344496        0x541B0         Nexus IMGDATA, entries: 0
344512        0x541C0         iRiver Database file
344528        0x541D0         InstallShield Cabinet archive data version 4/5, 0 files
344544        0x541E0         JAR (ARJ Software, Inc.) archive data
344560        0x541F0         VMware4 disk image
344592        0x54210         Xen saved domain file
344624        0x54230         lrzip compressed data
344656        0x54250         LUKS_MAGIC
344688        0x54270         Motorola bootlogo container
344704        0x54280         Motorola RLE bootlogo, width: 0, height: 0
344736        0x542A0         Microsoft WinCE install header, architecture-independent, 22094 files
344752        0x542B0         Microsoft WinCE install header, architecture-independent, 25192 files
344800        0x542E0         Neighborly text, "neighbor"
344816        0x542F0         Neighborly text, "neighbor"
344832        0x54300         Neighborly text, best guess: Goodspeed, "neighborlywowowowowowowow"
344976        0x54390         Zip multi-volume archive data, at least PKZIP v2.50 to extract
344992        0x543A0         Sony Playstation executable (ErCoMm)
345008        0x543B0         Qualcomm SBL1, image addr: 0, image size: 0, code size: 1095520339, sig size: 0, cert chain size: 4215883345, oem_root_cert_sel: 0, oem_num_root_certs: 0
345024        0x543C0         Qualcomm device tree container, version: 0, DTB entries: 0
345040        0x543D0         Qualcomm splash screen, width: 0, height: 0, type: 4215883345, blocks: 0
345056        0x543E0         QEMU QCOW Image
345072        0x543F0         rzip compressed data - version 0.0 (0 bytes)
345088        0x54400         OpenSSL encryption, salted, salt: 0x00
345136        0x54430         StuffIt Archive
345152        0x54440         StuffIt Archive (data): T!
345168        0x54450         StuffIt Deluxe (data): TD
345184        0x54460         StuffIt Deluxe Segment (data): f
345232        0x54490         SQLite 3.x database,
345360        0x54510         TWRP Backup,
345424        0x54550         VMware4 disk image
345440        0x54560         Aculab VoIP firmware format "orks\00"
345504        0x545A0         Beyonwiz firmware header, version: "02"
345520        0x545B0         WRGG firmware header, name: "", root device: "XTF0, 0x00, 0x00, 0x00"
345632        0x54620         XAR archive, version: 0, header size: 0, TOC compressed: 0, TOC uncompressed: 4847638125666631680, checksum: none
346160        0x54830         End of Zip archive, footer length: 22
```
