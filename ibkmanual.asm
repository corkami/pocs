; PE with a kernel range IMAGEBASE, but no relocations, only hand-corrected offsets

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

IMAGEBASE equ 0FFFF0000h ; ImageBase in kernel range to force relocation
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

%include "nthd_std.inc"

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    ; <== no reloc data
iend

%include 'section_1fa.inc'

;*******************************************************************************
EntryPoint:
    push msg + 20000h  ; <=== pre-relocated code
    call [__imp__printf +  20000h]
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess + 20000h]
_c

msg db " * kernel range IMAGEBASE (with manual relocations)", 0ah, 0

_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0

