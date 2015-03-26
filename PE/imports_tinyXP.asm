; imports with all tricks to make it as small as possible

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

IMAGEBASE equ 400000h
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
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE ; required under XP
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE    ; required under XP
iend

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * tiny imports", 0ah, 0
_d

ImportsAddressTable:
Import_Descriptor:
;kernel32.dll_DESCRIPTOR:
    dd 0
    msvcrt.dll_iat:
        __imp__printf:
            dd 80000000h + 742 ; printf
            dd 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;msvcrt.dll_DESCRIPTOR:
    dd 0
    kernel32.dll_iat:
        __imp__ExitProcess:
            dd 80000000h + 183 ; ExitProcess
            dd 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
kernel32.dll db 'kernel32' ,0 ; not W2k compatible
msvcrt.dll:
dd 'msvcrt',0
align 4, db 0 ; <= imports terminator NULL

IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable
_d

align FILEALIGN, db 0

