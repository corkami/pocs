; A file-targeted polymock
; (a file faking multiple file types, just via the minimum information)
; also contain some fake signatures to hopefully .

; Ange Albertini 2020, BSD-3


; generate with yasm -o multi multi.asm

; to be scanned with file --keep-going

; overlapping signatures are grouped


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macros

; hack to fill space until offset %1
%macro _at 1
  times (%1 - ($-$$)) db 0
%endmacro


; puts %2 at offset %1
%macro _ats 2
  _at %1
  %2
%endmacro


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File contents


_ats 0, {db "MZ"}       ; DOS executable
;ats 0, {db 0xff, 0xd8} ; JPEG
;ats 0, {db 0x1f, 0xb8} ; Gzip


_ats 2, {db 060h, 0EAh} ; ARJ


_ats 4, {db 088h, 0F0h, 39} ; MS Compress


_ats 7, {db 0CDh, 021h} ; fake INT 21h call to pretend it's a COM executable


;ats 12, {db "BB02"} ; Bacula volume
_ats 12, {db "SNDH"} ; SNDH Atari ST Music


_ats 16, {db "NRO0"} ; Nintendo Switch executable


_ats 20, {dd 0xfdc4a7dc} ; Zoo archive


_ats 24, {db 0x5D,0x1C,0x9E,0xA3} ; Nintendo Wii disc image
;ats 26, {db "sfArk"}  ; compressed SoundFont


_ats 32, {db "NXSB"}   ; Apple File System


;ats 36, {db "acsp"} ; ICC profile magic - not enough for detection
_ats 36, {dd 0x016f2818}  ; Linux kernel ARM boot executable zImage


;_ats 43, {db "SFDU_LABEL"} ; VICAR label file
_ats 44, {db "PTMF"}       ; Protracker
_ats 48, {db "SymExe"} ; SymbOs executable


;ats 56, {db "hpux"} ; netbsd ktrace, but requires extra conditions


_ats 60, {db "SONG"}     ; SoundFX Module sound file
;ats 60, {db "BOOKMOBI"} ; Mobipocket E-book
_ats 64, {dd 0xbeda107f}  ; VirtualBox Disk Image
;ats 65, {db "PNTGMPNT"} ; MacPaint Image data


;_ats 73, {db "%%%  "} ; BibTeX
_ats 76, {db "SCRS"}      ; Scream Tracker Sample


_ats 92, {db "PLOT%%84"}  ; Plot84 plotting file


_ats 109, {db "MAP ("}   ; EZD Electron Density Map


_ats 128, {db "DICM"} ; DICOM


;Rar
db "RE", 0x7e, 0x5e
db "Rar!", 0x17, 7, 0
db "Rar!", 0x17, 7, 1, 0


_ats 208, {db "MAP "} ; CCP4 Electron Density Map


_ats 256, {db "NCCH"} ; Nintendo 3DS archive
;ats 257, {db "ustar"} ; TAR
_ats 260, {db 0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B} ; Game Boy ROM image


_ats 369, {db "MICROSOFT PIFEX", 0} ; Windows Program Information File
;ats 384, {db "LockStream"}         ; LockStream Embedded file


db "7z", 0xBC, 0xAF, 0x27, 0x1C ; 7-zip


db 0xFD, "7zXZ", 0 ; XZ


db "LRZI" ; LRZIP


; LZ4
dd 0x184d2204
dd 0x184c2103
dd 0x184c2102


_ats 510, {db 055h, 0AAh} ; Master Boot Record


_ats 514, {db "HdrS"} ; Linux RW-rootFS


db "%PDF-1.4 obj stream endstream endobj xref trailer startxref" ; PDF

; ZIP structures
db "PK", 3,4
db "PK", 1,2
db "PK", 5,6

_ats 596, {db "X", 0DFh, 0FFh, 0FFh} ; Ultrix core file


db "X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H", "*" ; EICAR

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
