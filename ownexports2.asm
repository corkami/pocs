; PE with virtual and header exports

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    jmp [__imp__export2]
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

%include "nthd_std.inc"

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA, dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd import_descriptor - IMAGEBASE
iend

%include 'section_1fa.inc'

jmp part2

EntryPoint:
    push 0
    mov eax, ebx
    push dword [__imp__export]
    add dword [esp], 1
    retn
_c

part2:
    push export
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

export db " * virtual and header exports", 0ah, 0
_d

msvcrt.dll_iat: ;***************************************************************
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
ownexports.exe_iat:
__imp__export:
    dd hnexport - IMAGEBASE
__imp__export2:
    dd hnexport2 - IMAGEBASE
    dd 0
_d

import_descriptor:
_import_descriptor msvcrt.dll
_import_descriptor ownexports.exe
istruc IMAGE_IMPORT_DESCRIPTOR
iend

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

ownexports.exe_hintnames:
    dd hnexport - IMAGEBASE
    dd hnexport2 - IMAGEBASE
    dd 0

hnprintf:
    dw 0
    db 'printf', 0
hnexport:
    dw 0
    db 'offset -1', 0
hnexport2:
    dw 1
    db 'virtual', 0

msvcrt.dll db 'msvcrt.dll', 0
ownexports.exe db 'ownexports2.exe', 0

Exports_Directory:  ;************************************************************
istruc IMAGE_EXPORT_DIRECTORY
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd 2
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd 2
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_ordinals - IMAGEBASE
iend
_d

address_of_functions:
    dd -1 ; can't be 0
    dd EntryPoint - IMAGEBASE - 10
_d

address_of_names:
 dd hnexport + 2 - IMAGEBASE
 dd hnexport2 + 2 - IMAGEBASE

address_of_ordinals dw 0, 1

align FILEALIGN, db 0
