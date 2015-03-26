; a PE with big alignments

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

IMAGEBASE equ 10000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 20000000h
FILEALIGN equ 10000h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

%include 'nthd_std.inc'

%include 'dd_imports.inc'
%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * big alignments (10000h/20000000h)", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0
