; a PE with an imagebase as big as possible (with no relocations)

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

IMAGEBASE equ 7efd0000h ; 7ffd0000h also works under XP
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

%include 'nthd_std.inc'


%include 'dd_imports.inc'
%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * ImageBase is 7efd0000h, and no relocations", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0
