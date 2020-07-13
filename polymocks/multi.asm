; A file-targeted polymock
; (a file faking multiple file types, just via the minimum information)
; also contain some fake signatures to hopefully .

; Ange Albertini 2020, BSD-3


; generate with yasm -o multi multi.asm

; to be scanned with file --keep-going

; overlapping signatures are grouped


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macros

C equ 0
; hack to fill space until offset %1
%macro _at 1
  times (%1 - ($-$$)) db (C & 0xff) + 0
;  %assign C C+1
%endmacro


; put %2 at offset %1
%macro _ats 2
  _at %1
  %2
%endmacro


; extra signatures at variable offsets
%macro _ex 1
  %1
%endmacro


; signatures with padding
%macro _exa 1
  %1
  db 0
  align 16, db 0
%endmacro


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File contents


_ats 0, {db "MZ"}       ; DOS executable
;ats 0, {db 0xff, 0xd8} ; JPEG
;ats 0, {db 0x1f, 0xb8} ; Gzip


_ats 2, {db 060h, 0EAh} ; ARJ
;ats 2, {db "-LH1-"},   ; LHA archive (c64)


_ats 4, {db "jP"}           ; JPEG 2000
;ats 4, {db 088h, 0F0h, 39} ; MS Compress ; requires extra stuff
;ats 4, {db "ftyp"}         ; ISO MEDIA
;ats 4, {db "RED1"}         ; REDCode video
;ats 4, {db "pipe"}         ; Clipper instruction trace
;ats 4, {db "prof"}         ; Clipper instruction profile
;ats 4, {db " A~"}          ; Mathematica .ml
;ats 4, {db "PK", 1, 2}     ; Mozilla archive
;ats 4, {dd 0xfb4a}         ; QDos executable


_ats 6, {dw 0x0701}              ; unicos (cray) executable
;ats 6, {db "%!FontType1"}       ; PostScript Type 1 font program data
;ats 6, {db "%!PS-AdobeFont-1."} ; PostScript Type 1 font program data

;ats 7, {db "**ACE**"}           ; ACE archive
;ats 7, {dd 0x00454741}          ; DOS code page font data
;ats 7, {dd 0x00564944}          ; DOS code page font data (from Linux?)


_ats 8, {dd 0x10000419}          ; Symbian installation file
;ats 9, {db "PSUR"},             ; ARC archive (c64)


_ats 12, {db "SNDH"}     ; SNDH Atari ST Music
;ats 12, {db "BB02"}     ; Bacula volume
;ats 12, {dd 0x00040988} ; Berkeley DB

;ats 14, {db "U2ND"}        ;  BIN-Header
;ats 14, {db "\x1aJar\x1b"} ; JAR (ARJ Software, Inc.) archive data

_ats 16, {db "NRO0"} ; Nintendo Switch executable

;ats 18, {db "WDK\x202.0\x00"} ;  WDK file system, version 2.0

_ats 20, {dd 0xfdc4a7dc} ; Zoo archive


_ats 24, {db 0x5D,0x1C,0x9E,0xA3} ; Nintendo Wii disc image

	_ex {db "RE", 0x7e, 0x5e} ; Old Rar

;ats 26, {db "sfArk"}             ; compressed SoundFont

;ats 28, {db "make config"}       ; Linux make config build file (old)

_ats 32, {db "NXSB"}   ; Apple File System

;ats 34, {db "UPX!"}   ; FREE-DOS executable (COM), UPX compressed

;ats 35, {db "UPX!"}   ; FREE-DOS executable (COM), UPX compressed

;ats 36, {db "acsp"} ; ICC profile magic - not enough for detection
_ats 36, {dd 0x016f2818}  ; Linux kernel ARM boot executable zImage

;ats 40, {db "_FVH"} ; UEFI PI Firmware Volume

	_ex {db "PK", 3,4} ; Zip LFH

;_ats 43, {db "SFDU_LABEL"} ; VICAR label file

_ats 44, {db "PTMF"}       ; Poly Tracker Module File

_ats 48, {db "SymExe"}     ; SymbOs executable

	_ex {db "7z", 0xBC, 0xAF, 0x27, 0x1c} ; 7-zip

;ats 56, {db "hpux"} ; netbsd ktrace, but requires extra conditions


_ats 60, {db "SONG"}           ; SoundFX Module sound file
;ats 60, {db "BOOKMOBI"}       ; Mobipocket E-book
;ats 60, {db "W Collis", 0, 0} ; COM executable for MS-DOS, Compack compressed

;ats 63    , db "\x00ECEC" ; Windows CE memory segment header

_ats 64, {dd 0xbeda107f}       ; VirtualBox Disk Image

;ats 65, {db "PNTGMPNT"}       ; MacPaint Image data


_ats 70, {db 0CDh, 021h} ; fake INT 21h call to pretend it's a COM executable - also scanned on offsets 2, 4, 5, 13, 18, 23, 30, 70

	_ex {db "PK", 1,2} ; Zip CD

;_ats 73, {db "%%%  "} ; BibTeX
_ats 76, {db "SCRS"}      ; Scream Tracker Sample

	_ex {db "Rar!", 0x1A, 7, 1, 0} ; Rar v5
	_ex {db "LRZI"} ; LRZIP

_ats 92, {db "PLOT%%84"}  ; Plot84 plotting file

	_ex {db "Rar!", 0x1A, 7, 0} ; Rar v4

_ats 109, {db "MAP ("}   ; EZD Electron Density Map

	_ex {db 0xFD, "7zXZ", 0} ; XZ
	_ex {dd 0x184d2204} ; LZ4
	_ex {dd 0x184c2103} ; LZ4

_ats 128, {db "DICM"} ; DICOM

	_ex {db "%PDF-1.4 obj stream endstream endobj xref trailer startxref"} ; PDF

;_ats 192, {db "\044\377\256Qi\232"} ; Nintendo DS Game ROM Image

_ats 208, {db "MAP "} ; CCP4 Electron Density Map


;ats 252, {db "Must have DOS version"} ; DR-DOS executable (COM)


_ats 256, {db "NCCH"} ; Nintendo 3DS archive


;ats 257, {db "ustar"} ; TAR


_ats 260, {db 0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B} ; Game Boy ROM image


_ats 369, {db "MICROSOFT PIFEX", 0} ; Windows Program Information File


;ats 384, {db "LockStream"}         ; LockStream Embedded file

	_ex {dd 0x184c2102} ; LZ4

_ats 510, {db 055h, 0AAh} ; Master Boot Record


_ats 514, {db "HdrS"} ; Linux RW-rootFS


_ats 596, {db "X", 0DFh, 0FFh, 0FFh} ; Ultrix core file

	_ex {db "X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H", "*"} ; EICAR

_ats 1008, {db "DECFILE11"} ; Files-11 On-Disk Structure


_ats 1024, {dd 0xF2F52010} ; F2FS filesystem
;at 1024, {dw 0x2b48} ; Macintosh HFS Extended


_ats 1028, {db "MMX", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} ; MAR Area Detector Image


;ats 1062, {db "MaDoKaN96"} ; XMS Adlib Module
_ats 1068, {db "RoR"} ; AMUSIC Adlib Tracker


_ats 1080, {db "4CHN"} ; FastTracker


_ats 1090, {db 019h, 0DBh, 0D8h, 0E2h, 0D9h, 0C4h, 0E2h, 0E2h, 0D7h, 0C3h} ; IBM OS/400 save file (search)


_ats 2048, {db "PCD_IPI"} ; Kodak Photo CD
;ats 2048, {dd 0x0027fc46} ; Atari-ST Minix kernel image


;ats 4096, {dd 0xa92b4efc} ; Linux Software RAID
_ats 4098, {db "DOSFONT"}  ; DOSFONT2 encrypted font data


_ats 9564, {dd 0x00011954} ; Unix Fast FS v1


_ats 32769, {db "CD001"} ; ISO


_ats 32777, {db "CDROM"} ; High Sierra CDRom


_ats 37633, {db "CD001"} ; ISO RAW


_ats 42332, {dd 0x19540119}  ; Unix Fast FS v2


_ats 65588, {db "ReIsEr2Fs"} ;ReiserFS V3.6"


_ats 66908, {dd 0x19540119} ; Unix Fast FS v2


_ats 91392, {dd 0x00410112} ; D64 Image

_ats 339969, {db "CD001"} ; Nero ISO

align 16, db 0

; Binwalk stuff
_exa {db "%%OID_ATT_DLM_NAME"} ; Xerox DLM firmware name:
_exa {db "%%OID_ATT_DLM_VERSION"} ; Xerox DLM firmware version:
_exa {db "%%XRXbegin"} ; Xerox DLM firmware start of header
_exa {db "%%XRXend"} ; Xerox DLM firmware end of header
_exa {db "%PDF-"} ; PDF document,
_exa {db "-----BEGIN PGP"} ; PGP armored data,
_exa {db "-----BEGIN CERTIFICATE"} ; PEM certificate
_exa {db "-----BEGIN CERTIFICATE REQ"} ; PEM certificate request
_exa {db "-----BEGIN DSA PRIVATE"} ; PEM DSA private key
_exa {db "-----BEGIN EC PRIVATE"} ; PEM EC private key
_exa {db "-----BEGIN RSA PRIVATE"} ; PEM RSA private key
_exa {db "--PaCkImGs"} ; PackImg section delimiter tag,
_exa {db "-rom1fs-", 0} ; romfs filesystem, version 1
_exa {db "070701"} ; ASCII cpio archive (SVR4 with no CRC),
_exa {db "070702"} ; ASCII cpio archive (SVR4 with CRC)
_exa {db 1, "gpg"} ; GPG key trust database
_exa {db 0x27, "%-12345X@PJL"} ; HP Printer Job Language data,
_exa {db "\056\000\000\352$\377\256Qi"} ;Nintendo Game Boy Advance ROM Image
_exa {db 0,0,0, "C", 0,0,0, "R"} ; BLCR
_exa {db 0, "m", 2} ; mcrypt 2.2 encrypted data,
_exa {db 0, "m", 3} ; mcrypt 2.5 encrypted data,

_exa {db 027h, "ELF"} ; ELF,
_exa {db 089h, "LZO", 0, 0dh, 0ah, 1ah, 0ah} ; LZO compressed data
_exa {db 0x89, 0x4c, 0x5a, 0x4f, 0x00, 0x0d, 0x0a, 0x1a, 0x0a} ; lzop compressed data,

_exa {db 0xe9,",", 1, "JAM"} ; JAM archive
_exa {db 0x00, 0x00, 0x00, 0x00, 0x77, 0x07, 0x30, 0x96, 0xEE, 0x0E, 0x61, 0x2C, 0x99, 0x09, 0x51, 0xBA} ; CRC32 polynomial table, big endian
_exa {db 0x00, 0x00, 0x00, 0x00, 0x96, 0x30, 0x07, 0x77, 0x2C, 0x61, 0x0E, 0xEE, 0xBA, 0x51, 0x09, 0x99} ; CRC32 polynomial table, little endian

_exa {db 0x00, 0x04, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x04, 0x01, 0x01, 0x04, 0x00, 0x01, 0x01, 0x04, 0x04, 0x01, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00} ;DES SP1, little endian{overlap}
_exa {db 0x01, 0x01, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0x01, 0x04, 0x04, 0x01, 0x01, 0x00, 0x04, 0x00, 0x01, 0x04, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0x00, 0x00} ;DES SP1, big endian
_exa {db 0x20, 0x80, 0x10, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x00, 0x20, 0x80, 0x10, 0x00, 0x00, 0x00, 0x10, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x10, 0x80, 0x20, 0x80, 0x00, 0x80} ;DES SP2, little endian
_exa {db 0x80, 0x10, 0x80, 0x20, 0x80, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x10, 0x80, 0x20, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x80, 0x10, 0x00, 0x20, 0x80, 0x00, 0x80, 0x20} ;DES SP2, big endian
_exa {db 0x38, 0x30, 0x28, 0x20, 0x18, 0x10, 0x08, 0x00, 0x39, 0x31, 0x29, 0x21, 0x19, 0x11, 0x09, 0x01, 0x3a, 0x32, 0x2a, 0x22, 0x1a, 0x12, 0x0a, 0x02, 0x3b, 0x33, 0x2b, 0x23, 0x3e, 0x36, 0x2e, 0x26, 0x1e, 0x16, 0x0e, 0x06, 0x3d, 0x35, 0x2d, 0x25, 0x1d, 0x15, 0x0d, 0x05, 0x3c, 0x34, 0x2c, 0x24, 0x1c, 0x14, 0x0c, 0x04, 0x1b, 0x13, 0x0b, 0x03} ;DES PC1 table
_exa {db 0x0d, 0x10, 0x0a, 0x17, 0x00, 0x04, 0x02, 0x1b, 0x0e, 0x05, 0x14, 0x09, 0x16, 0x12, 0x0b, 0x03, 0x19, 0x07, 0x0f, 0x06, 0x1a, 0x13, 0x0c, 0x01, 0x28, 0x33, 0x1e, 0x24, 0x2e, 0x36, 0x1d, 0x27, 0x32, 0x2c, 0x20, 0x2f, 0x2b, 0x30, 0x26, 0x37, 0x21, 0x34, 0x2d, 0x29, 0x31, 0x23, 0x1c, 0x1f} ;DES PC2 table

_exa {db 0x00, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20} ; LBR archive data
_exa {db 0x00, 0x53, 0x46, 0x48} ; OSX DMG image
_exa {db 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00} ; YAFFS filesystem, little endian
_exa {db 0x0a, 0x0d, 0x0d, 0x0a, 0x1a, 0x2b, 0x3c, 0x4d} ; Pcap-ng capture file, big-endian,
_exa {db 0x0a, 0x0d, 0x0d, 0x0a, 0x4d, 0x3c, 0x2b, 0x1a} ; Pcap-ng capture file, little-endian,
_exa {db 0x0E, 0x00, 0x4D, 0x43, 0x61, 0x73, 0x74, 0x46, 0x53, 0x32, 0x00, 0x00} ; Amino MCastFS2 (.mcfs)
_exa {db 0x1f, 0x8b, 0x08} ; gzip compressed data
_exa {db 0x23, 0x21, "/"} ; Executable script,
_exa {db 0x23, 0x21, 0x20, "/"} ; Executable script,
_exa {db 0x23, 0x40, 0x7e, 0x5e} ; Windows Script Encoded Data (screnc.exe)
_exa {db 0x30, 0x82} ; Certificate in DER format (x509 v3),
_exa {db 0x30, 0x82} ; Object signature in DER format (PKCS#7),
_exa {db 0x30, 0x82} ; Private key in DER format (PKCS#8),

_exa {db 1, 0,0,0,0,0,0, 0xc0,0,2,0,0} ; Marvell Libertas firmware
_exa {db 0x36, 0x00, 0x00, 0x00} ; Broadcom 96345 firmware header, header size: 256,
_exa {db 0x5e, 0xa3, 0xa4, 0x17} ; DLOB firmware header,{jump:108}

_exa {db "<html"} ; HTML document header
_exa {db "</html>"} ; HTML document footer
_exa {db "<?xml version"} ; XML document,

_exa {db 0x42, 0x8a, 0x2f, 0x98, 0x71, 0x37, 0x44, 0x91, 0xb5, 0xc0, 0xfb, 0xcf, 0xe9, 0xb5, 0xdb, 0xa5} ; SHA256 hash constants, big endian
_exa {db 0x98, 0x2f, 0x8a, 0x42, 0x91, 0x44, 0x37, 0x71, 0xcf, 0xfb, 0xc0, 0xb5, 0xa5, 0xdb, 0xb5, 0xe9} ; SHA256 hash constants, little endian

_exa {db 0x47, 0x40, 0x00} ; MPEG transport stream data
_exa {db 0x47, 0x60, 0x00} ; MPEG transport stream data
_exa {db 0x47, 0xC0, 0x00} ; MPEG transport stream data
_exa {db 0x47, 0xE0, 0x00} ; MPEG transport stream data

_exa {db 0x4B, 0x47, 0x42, 0x5F, 0x61, 0x72, 0x63, 0x68, 0x20, 0x2D} ; KGB archive
_exa {db 0x52, 0x61, 0x72, 0x21, 0x1A, 0x07} ; RAR archive data,

_exa {db 0x62, 0x70, 0xe0, 0x3b, 0x51, 0x1d, 0xd2, 0x45, 0x83, 0x2b, 0xf0, 0x93, 0x25, 0x7e, 0xd4, 0x61} ; Toshiba EFI capsule
_exa {db 0x68, 0x19, 0x11, 0x22} ; QNX6 Super Block

_exa {db 0x69, 0xF6, 0x00, 0x0B, 0x68, 0xF6} ; SuperH instructions, big endian, function epilogue (gcc)
_exa {db 0xF6, 0x69, 0x0B, 0x00, 0xF6, 0x68} ; SuperH instructions, little endian, function epilogue (gcc)

_exa {db 0x51, 0x00, 0x00} ; LZMA compressed data, properties: 0x51,
_exa {db 0x5A, 0x00, 0x00} ; LZMA compressed data, properties: 0x5A,
_exa {db 0x5B, 0x00, 0x00} ; LZMA compressed data, properties: 0x5B,
_exa {db 0x5C, 0x00, 0x00} ; LZMA compressed data, properties: 0x5C,
_exa {db 0x5D, 0x00, 0x00} ; LZMA compressed data, properties: 0x5D,
_exa {db 0x5E, 0x00, 0x00} ; LZMA compressed data, properties: 0x5E,
_exa {db 0x63, 0x00, 0x00} ; LZMA compressed data, properties: 0x63,
_exa {db 0x64, 0x00, 0x00} ; LZMA compressed data, properties: 0x64,
_exa {db 0x65, 0x00, 0x00} ; LZMA compressed data, properties: 0x65,
_exa {db 0x66, 0x00, 0x00} ; LZMA compressed data, properties: 0x66,
_exa {db 0x6C, 0x00, 0x00} ; LZMA compressed data, properties: 0x6C,
_exa {db 0x6D, 0x00, 0x00} ; LZMA compressed data, properties: 0x6D,
_exa {db 0x6E, 0x00, 0x00} ; LZMA compressed data, properties: 0x6E,
_exa {db 0x75, 0x00, 0x00} ; LZMA compressed data, properties: 0x75,
_exa {db 0x76, 0x00, 0x00} ; LZMA compressed data, properties: 0x76,
_exa {db 0x7E, 0x00, 0x00} ; LZMA compressed data, properties: 0x7E,
_exa {db 0x87, 0x00, 0x00} ; LZMA compressed data, properties: 0x87,
_exa {db 0x88, 0x00, 0x00} ; LZMA compressed data, properties: 0x88,
_exa {db 0x89, 0x00, 0x00} ; LZMA compressed data, properties: 0x89,
_exa {db 0x8A, 0x00, 0x00} ; LZMA compressed data, properties: 0x8A,
_exa {db 0x8B, 0x00, 0x00} ; LZMA compressed data, properties: 0x8B,
_exa {db 0x90, 0x00, 0x00} ; LZMA compressed data, properties: 0x90,
_exa {db 0x91, 0x00, 0x00} ; LZMA compressed data, properties: 0x91,
_exa {db 0x92, 0x00, 0x00} ; LZMA compressed data, properties: 0x92,
_exa {db 0x93, 0x00, 0x00} ; LZMA compressed data, properties: 0x93,
_exa {db 0x99, 0x00, 0x00} ; LZMA compressed data, properties: 0x99,
_exa {db 0x9A, 0x00, 0x00} ; LZMA compressed data, properties: 0x9A,
_exa {db 0x9B, 0x00, 0x00} ; LZMA compressed data, properties: 0x9B,
_exa {db 0xA2, 0x00, 0x00} ; LZMA compressed data, properties: 0xA2,
_exa {db 0xA3, 0x00, 0x00} ; LZMA compressed data, properties: 0xA3,
_exa {db 0xAB, 0x00, 0x00} ; LZMA compressed data, properties: 0xAB,
_exa {db 0xB4, 0x00, 0x00} ; LZMA compressed data, properties: 0xB4,
_exa {db 0xB5, 0x00, 0x00} ; LZMA compressed data, properties: 0xB5,
_exa {db 0xB6, 0x00, 0x00} ; LZMA compressed data, properties: 0xB6,
_exa {db 0xB7, 0x00, 0x00} ; LZMA compressed data, properties: 0xB7,
_exa {db 0xB8, 0x00, 0x00} ; LZMA compressed data, properties: 0xB8,
_exa {db 0xBD, 0x00, 0x00} ; LZMA compressed data, properties: 0xBD,
_exa {db 0xBE, 0x00, 0x00} ; LZMA compressed data, properties: 0xBE,
_exa {db 0xBF, 0x00, 0x00} ; LZMA compressed data, properties: 0xBF,
_exa {db 0xC0, 0x00, 0x00} ; LZMA compressed data, properties: 0xC0,
_exa {db 0xC6, 0x00, 0x00} ; LZMA compressed data, properties: 0xC6,
_exa {db 0xC7, 0x00, 0x00} ; LZMA compressed data, properties: 0xC7,
_exa {db 0xC8, 0x00, 0x00} ; LZMA compressed data, properties: 0xC8,
_exa {db 0xCF, 0x00, 0x00} ; LZMA compressed data, properties: 0xCF,
_exa {db 0xD0, 0x00, 0x00} ; LZMA compressed data, properties: 0xD0,
_exa {db 0xD8, 0x00, 0x00} ; LZMA compressed data, properties: 0xD8,
_exa {db 0xFF, "LZMA", 0x00} ; LZMA compressed data (new),

_exa {db 0x85, 0x01, 0x14} ; Cisco IOS microcode,
_exa {db 0x85, 0x01, 0xcb} ; Cisco IOS experimental microcode,

_exa {db 0x84, 0x8c, 0x03} ; PGP RSA encrypted session key -
_exa {db 0x85, 0x01, 0x0c, 0x03} ; PGP RSA encrypted session key -
_exa {db 0x85, 0x01, 0x8c, 0x03} ; PGP RSA encrypted session key -
_exa {db 0x85, 0x02, 0x0c, 0x03} ; PGP RSA encrypted session key -
_exa {db 0x85, 0x04, 0x0c, 0x03} ; PGP RSA encrypted session key -

_exa {db 0x89, "PNG", 0x0d, 0x0a, 0x1a, 0x0a} ; PNG image
_exa {db 0x8b, 0xa6, 0x3c, 0x4a, 0x23, 0x77, 0xfb, 0x48, 0x80, 0x3d, 0x57, 0x8c, 0xc1, 0xfe, 0xc4, 0x4d} ; AMI Aptio extended EFI capsule
_exa {db 0x90, 0xbb, 0xee, 0x14, 0x0a, 0x89, 0xdb, 0x43, 0xae, 0xd1, 0x5d, 0x3c, 0x45, 0x88, 0xa4, 0x18} ; AMI Aptio unsigned EFI capsule
_exa {db 0xa1, 0xb2, 0xc3, 0xd4, 0x00} ; Libpcap capture file, big-endian,
_exa {db 0xbe, 0xef, "ABCDEFGH"} ; HP LaserJet 1000 series downloadable firmware
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00} ; Compiled Java class data,

_exa {db 0xBD, 0x86, 0x66, 0x3B, 0x76, 0x0D, 0x30, 0x40, 0xB7, 0x0E, 0xB5, 0x51, 0x9E, 0x2F, 0xC5, 0xA0} ; EFI capsule v0.9
_exa {db 0xb9, 0x82, 0x91, 0x53, 0xb5, 0xab, 0x91, 0x43, 0xb6, 0x9a, 0xe3, 0xa9, 0x43, 0xf7, 0x2f, 0xcc} ; UEFI capsule
_exa {db 0xb8, 0xc0, 0x07, 0x8e, 0xd8, 0xb8, 0x00, 0x90, 0x8e, 0xc0, 0xb9, 0x00, 0x01, 0x29, 0xf6, 0x29} ; Linux kernel boot image

_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x01} ; Mach-O universal binary with 1 architecture
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x02} ; Mach-O universal binary with 2 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x03} ; Mach-O universal binary with 3 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x04} ; Mach-O universal binary with 4 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x05} ; Mach-O universal binary with 5 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x06} ; Mach-O universal binary with 6 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x07} ; Mach-O universal binary with 7 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x08} ; Mach-O universal binary with 8 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x0a} ; Mach-O universal binary with 9 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x0b} ; Mach-O universal binary with 10 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x0c} ; Mach-O universal binary with 11 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x0d} ; Mach-O universal binary with 12 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x0e} ; Mach-O universal binary with 13 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x0f} ; Mach-O universal binary with 14 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x10} ; Mach-O universal binary with 15 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x11} ; Mach-O universal binary with 16 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x12} ; Mach-O universal binary with 17 architectures
_exa {db 0xca, 0xfe, 0xba, 0xbe, 0x00, 0x00, 0x00, 0x13} ; Mach-O universal binary with 18 architectures

_exa {db 0xEB, 0x10, 0x90, 0x00} ; QNX4 Boot Block
_exa {db 0xEB, 0x7E, 0xFF, 0x00} ; QNX IFS,

_exa {db 0xFD, 0x37, 0x7a, 0x58, 0x5a, 0x00} ; xz compressed data

_exa {db 0xfe, 0xfe, 0x03} ; MySQL MISAM index file
_exa {db 0xfe, 0xfe, 0x05} ; MySQL ISAM index file
_exa {db 0xfe, 0xfe, 0x06} ; MySQL ISAM compressed data file
_exa {db 0xfe, 0xfe, 0x07} ; MySQL MISAM compressed data file

_exa {db 0xff, 0x06, 0x00, 0x00, 0x73, 0x4e, 0x61, 0x50, 0x70, 0x59} ; Snappy compression, stream identifier

_exa {db "__UTAG_HEAD__", 0x00} ; Motorola UTAGS

_exa {db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"} ; Base64 standard index table
_exa {db "ACEGIKMOQSUWYBDFHJLNPRTVXZacegikmoqsuwybdfhjlnprtvxz0246813579=+/"} ; Base64 SerComm index table

_exa {db "AIH0"} ; AIH0 firmware header, header size: 48,
_exa {db "BLI223WJ0"} ; Thompson/Alcatel encoded firmware,
_exa {db "CI032.00"} ; Cisco VxWorks firmware header,

_exa {db "ANDROID!"} ; Android bootimg
_exa {db 'ANDROID BACKUP\n'} ; Android Backup
_exa {db "B000FF"} ; Windows CE image header,
_exa {db "BBBB"} ;Boot section{overlap}
_exa {db "BCRM"} ; Broadcom header,
_exa {db "begin "} ; uuencoded data,
_exa {db "bFLT"} ; BFLT executable
_exa {db "BM"} ; PC bitmap,
_exa {db "BOOTLDR!"} ; Nexus bootloader image
_exa {db "BOOTLOADER!"} ; Mediatek bootloader
_exa {db "BORG_SEG"} ; BORG Backup Archive
_exa {db "BRLYT", 0x00, 0x00, 0x00} ;Mediatek Boot Header
_exa {db "BSA", 0x00, 0x67} ; BSA archive, version: 103,
_exa {db "BSA", 0x00, 0x68} ; BSA archive, version: 104,

_exa {db "BZh11AY&SY"} ; bzip2 compressed data, block size = 100k
_exa {db "BZh21AY&SY"} ; bzip2 compressed data, block size = 200k
_exa {db "BZh31AY&SY"} ; bzip2 compressed data, block size = 300k
_exa {db "BZh41AY&SY"} ; bzip2 compressed data, block size = 400k
_exa {db "BZh51AY&SY"} ; bzip2 compressed data, block size = 500k
_exa {db "BZh61AY&SY"} ; bzip2 compressed data, block size = 600k
_exa {db "BZh71AY&SY"} ; bzip2 compressed data, block size = 700k
_exa {db "BZh81AY&SY"} ; bzip2 compressed data, block size = 800k
_exa {db "BZh91AY&SY"} ; bzip2 compressed data, block size = 900k

_exa {db "Cobalt Networks Inc.\nFirmware v"} ; Paged COBALT boot rom
_exa {db "Copyright"} ; Copyright string:

_exa {db "COWD", 0x02} ; VMWare3 undoable disk image,
_exa {db "COWD", 0x03} ; VMWare3 disk image,

_exa {db "CRfs"} ; COBALT boot rom data (Flat boot rom or file system)
_exa {db "CSR-dfu2"} ; CSR (XAP2) DFU firmware update header
_exa {db "CSRbcfw1"} ; CSR Bluecore firmware segment
_exa {db "CSYS", 0x00} ; CSYS header, little endian, 
_exa {db "CSYS", 0x80} ; CSYS header, big endian,
_exa {db "d8:announce"} ; BitTorrent file
_exa {db "DOSEMU\0"} ; DOS Emulator image

_exa {db "ecdsa-sha2-nistp256 "} ;OpenSSH ECDSA (Curve P-256) public key
_exa {db "ecdsa-sha2-nistp384 "} ;OpenSSH ECDSA (Curve P-384) public key
_exa {db "ecdsa-sha2-nistp521 "} ;OpenSSH ECDSA (Curve P-521) public key
_exa {db "ssh-dss "} ; OpenSSH DSA public key
_exa {db "ssh-rsa "} ; OpenSSH RSA public key
_exa {db "SSH PRIVATE KEY"} ; OpenSSH RSA1 private key,

_exa {db 0x40, 0x1A, 0x68, 0x00, 0x00, 0x00, 0x00, 0x00, 0x33, 0x5A, 0x00, 0x7F} ; eCos kernel exception handler, architecture: MIPS,
_exa {db 0x00, 0x68, 0x1A, 0x40, 0x00, 0x00, 0x00, 0x00, 0x7F, 0x00, 0x5A, 0x33} ; eCos kernel exception handler, architecture: MIPSEL,
_exa {db 0x00, 0x68, 0x1A, 0x40, 0x7F, 0x00, 0x5A, 0x33} ; eCos kernel exception handler, architecture: MIPSEL,
_exa {db 0x40, 0x1A, 0x68, 0x00, 0x33, 0x5A, 0x00, 0x7F} ; eCos kernel exception handler, architecture: MIPS,
_exa {db "ecos"} ; eCos RTOS string reference:
_exa {db "ECOS"} ; eCos RTOS string reference:
_exa {db "eCos"} ; eCos RTOS string reference:

_exa {db "ELSB"} ; LANCOM firmware loader,
_exa {db "ELSC"} ; LANCOM WWAN firmware
_exa {db "ELSF"} ; LANCOM firmware header,
_exa {db "ELSO"} ; LANCOM OEM file
_exa {db "ELSP"} ; LANCOM file entry

_exa {db "EMMC_BOOT", 0x00, 0x00, 0x00} ; Mediatek EMMC Flash Image
_exa {db "ESTFBINR"} ; EST flat binary
_exa {db "FILE_INFO", 0x00, 0x00, 0x00} ;Mediatek File Info
_exa {db "FNIB"} ; ZBOOT firmware header, header size: 32 bytes,
_exa {db "FS", 0x3C, 0x3C} ; BSD 2.x filesystem,
_exa {db "FWS"} ; Uncompressed Adobe Flash SWF file,
_exa {db "G614"} ; Realtek firmware header, ROME bootloader,
_exa {db "GEOS"} ; Ubiquiti firmware header, header size: 264 bytes,
_exa {db "GIF8"} ; GIF image data
_exa {db "GNU tar-"} ; GNU tar incremental snapshot data,
_exa {db "HDR0"} ; TRX firmware header, little endian,
_exa {db "HPAK"} ; HPACK archive data

_exa {db "HP38Asc"} ; HP 38 ASCII
_exa {db "HP38Bin"} ; HP 38 binary
_exa {db "HP39Asc"} ; HP 39 ASCII
_exa {db "HP39Bin"} ; HP 39 binary
_exa {db "HPHP48"} ; HP 48 binary
_exa {db "HPHP49"} ; HP 49 binary

_exa {db "hsqs"} ; Squashfs filesystem, little endian,
_exa {db "hsqt"} ; Squashfs filesystem, little endian, DD-WRT signature,

_exa {db "icpnas"} ; QNAP encrypted firmware footer
_exa {db "ID", 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00} ; Toshiba SSD Firmware Update
_exa {db "II", 0x2a, 0x00} ; TIFF image data, little-endian
_exa {db "IMG0"} ; IMG0 (VxWorks) header,
_exa {db "IMGDATA!"} ; Nexus IMGDATA
_exa {db "iRivDB"} ; iRiver Database file
_exa {db "ISc("} ; InstallShield Cabinet archive data
_exa {db "JARCS"} ; JAR (ARJ Software, Inc.) archive data
_exa {db "KDMV"} ; VMware4 disk image
_exa {db "Linux version "} ; Linux kernel version
_exa {db "LinuxGuestRecord"} ; Xen saved domain file
_exa {db "LRZI"} ; lrzip compressed data
_exa {db "LZIP"} ; lzip compressed data,
_exa {db "LUKS", 0xBA, 0xBE} ; LUKS_MAGIC
_exa {db "MM", 0x00, 0x2a} ; TIFF image data, big-endian,

_exa {db "MotoLogo", 0x00} ; Motorola bootlogo container
_exa {db "MotoRun", 0x00} ; Motorola RLE bootlogo
_exa {db "MPFS"} ; MPFS filesystem, Microchip,

_exa {db "MSCE",0,0,0,0} ; Microsoft WinCE install header
_exa {db "MSCE",0,0,0,0} ; Microsoft WinCE installer
_exa {db "MSCF",0,0,0,0} ; Microsoft Cabinet archive data

_exa {db "N^NuNV"} ; Motorola Coldfire instructions, function prologue/epilogue
_exa {db "neighbor"} ; Neighborly text,
_exa {db "neighbor"} ; Neighborly text,
_exa {db "neighborly"} ; Neighborly text, best guess: Goodspeed, 
_exa {db "NOR_BOOT", 0x00, 0x00, 0x00, 0x00} ;Mediatek NOR Flash Image
_exa {db "OPEN"} ; Ubiquiti firmware header, third party,
_exa {db "owowowowowowowowowowowowowowow"} ; Wind River management filesystem,{overlap}
_exa {db "owowowowowowowowowowowowowowow"} ; Wind River management filesystem,{overlap}
_exa {db "PAR\0"} ; PARity archive data
_exa {db "PFS/"} ; PFS filesystem,

_exa {db "PK", 0x07, 0x08, "PK", 0x03, 0x04} ; Zip multi-volume archive data, at least PKZIP v2.50 to extract

_exa {db "PS-X EXE"} ; Sony Playstation executable

_exa {db 0xd1, 0xdc, 0x4b, 0x84, 0x34, 0x10, 0xd7, 0x73} ; Qualcomm SBL1
_exa {db "QCDT"} ; Qualcomm device tree container
_exa {db "SPLASH!!"} ; Qualcomm splash screen

_exa {db "QFI", 0xFB} ; QEMU QCOW Image
_exa {db "RZIP"} ; rzip compressed data
_exa {db "Salted__"} ; OpenSSL encryption, salted,
_exa {db "sErCoMm"} ; Sercomm firmware signature,
_exa {db "SF_BOOT", 0x00, 0x00, 0x00, 0x00, 0x00} ; Mediatek Serial Flash Image

_exa {db "StuffIt"} ; StuffIt Archive
_exa {db "SIT!"} ; StuffIt Archive (data)
_exa {db "SITD"} ; StuffIt Deluxe (data)
_exa {db "Sef"} ; StuffIt Deluxe Segment (data)

_exa {db 0x2A, 0x2A, "This file contains an SQLite"} ; SQLite 2.x database
_exa {db "SQLite format 3"} ; SQLite 3.x database,

_exa {db "shsq"} ; Squashfs filesystem, little endian, non-standard signature, 
_exa {db "sqlz"} ; Squashfs filesystem, big endian, lzma compression, 
_exa {db "qshs"} ; Squashfs filesystem, big endian, lzma signature,
_exa {db "sqsh"} ; Squashfs filesystem, big endian,
_exa {db "tqsh"} ; Squashfs filesystem, big endian, DD-WRT signature,

_exa {db "TOC", 0x00, 0x00, 0x00, 0x00} ; Samsung modem TOC index,
_exa {db "TROC"} ; TROC filesystem,
_exa {db "TWRP", 0x00, 0x00, 0x00, 0x00} ; TWRP Backup,
_exa {db "UBI!"} ; UBI volume ID header,
_exa {db "UBI", 0x23} ; UBI erase count header,
_exa {db "UBNT"} ; Ubiquiti firmware header, header size: 264 bytes,
_exa {db "VMDK"} ; VMware4 disk image
_exa {db "VoIP Startup and"} ; Aculab VoIP firmware

_exa {db "VxWorks\00"} ; VxWorks operating system version
_exa {db "WIND version "} ; VxWorks WIND kernel version

_exa {db "WizFwPkgl"} ; Beyonwiz firmware header,
_exa {db "wrgg02"} ; WRGG firmware header,

_exa {db "XBEH"} ; Microsoft Xbox executable (XBE),
_exa {db "XIP0"} ; XIP, Microsoft Xbox data,
_exa {db "XTF0, 0x00, 0x00, 0x00"} ; XTF, Microsoft Xbox data
_exa {db "ZyXEL\002"} ; ZyXEL voice data

_exa {db "Ck", 0,0,0, "R", 0,0,0} ; BLCR
_exa {db "xar!"} ; XAR archive
_exa {db "CFE1"} ;CFE boot loader
_exa {db "U-Boot "} ;} ;U-Boot version string,

_exa {db 0x27, 0xBD, 0xFF} ;MIPS instructions, function prologue
_exa {db 0x38, 0x00, 0x00, 0x00} ;Broadcom firmware header
_exa {db 0x55, 0x89, 0xE5, 0x57, 0x56} ;Intel x86 instructions, function prologue
_exa {db 0x55, 0x89, 0xE5, 0x83, 0xEC} ;Intel x86 instructions, function prologue
_exa {db 0x81, 0xC7, 0xE0, 0x08, 0x81, 0xE8} ;SPARC instructions, function epilogue
_exa {db 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90} ;Intel x86 instructions, nops{jump:8}{overlap}
_exa {db 0xEB, 0xCD, 0x40, 0x80, 0x1A, 0x97} ;AVR32 instructions, function prologue
_exa {db 0xf0, 0x08, 0x64} ;MIPS16e instructions, function prologue
_exa {db 0x00, 0x00, 0x22, 0xE1} ;Ubicom32 instructions, function epilogue
_exa {db 0x02, 0xFF, 0x61, 0x25} ;Ubicom32 instructions, function prologue
_exa {db 0x93, 0xCF, 0x93, 0xDF} ;AVR8 instructions, function prologue
_exa {db 0x93, 0xDF, 0x93, 0xCF} ;AVR8 instructions, function prologue
_exa {db 0xF0, 0xA0, 0x00, 0xA0} ;Ubicom32 instructions, function epilogue
_exa {db 0x03, 0xe0, 0x00, 0x08} ;MIPS instructions, function epilogue
_exa {db 0x4E, 0x80, 0x00, 0x20} ;PowerPC big endian instructions, function epilogue
_exa {db 0x7C, 0x08, 0x02, 0xA6} ;PowerPC big endian instructions, function prologue
_exa {db 0xe8, 0xa0, 0x65, 0x00} ;MIPS16e instructions, function epilogue

_exa {dw 0xE1A0} ;ARM instructions, function epilogue{adjust:-2}
_exa {dw 0xE92D} ;ARM instructions, function prologue{adjust:-2}
_exa {db 0xE1, 0xA0} ;ARMEB instructions, function epilogue
_exa {db 0xE9, 0x2D} ;ARMEB instructions, function prologue

_exa {dd 0x4E800020} ;PowerPC little endian instructions, function epilogue
_exa {dd 0x7C0802A6} ;PowerPC little endian instructions, function prologue

_exa {dd 0xe8a06500} ;MIPSEL16e instructions, function epilogue
_exa {dd 0x03e00008} ;MIPSEL instructions, function epilogue
_exa {db 0x27, 0xBD} ;MIPS instructions, function epilogue
_exa {db 0x65, 0xB9} ;MIPS16e instructions, function epilogue
_exa {db 0xFF, 0xBD, 0x27} ; MIPSEL instructions, function prologue
_exa {dw 0x27BD} ;MIPS instructions, function epilogue
_exa {dw 0x65B9} ;MIPSEL16e instructions, function epilogue

_exa {db "PK", 5,6} ; ZIP EoCD
