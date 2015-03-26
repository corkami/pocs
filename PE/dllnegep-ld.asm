; dll static loader ; TODO: broken

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

IMAGEBASE equ 1400000h ; <====
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

%include "nthd_std.inc"

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
	retn
; fake export of the dllmain starts here
	push 01001000h ; data in the DLL
    call [__imp__printf]
	add esp, 1 * 4
	xor eax, eax
	inc eax
	retn 0ch
_c

MSG db ' * negative entrypoint for DllMain in the EXE', 0

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor dll.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
_d

dll.dll_hintnames:
    dd hndllexport - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
_d

hndllexport:
    dw 0
    db 'export', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0
_d
dll.dll_iat:
__imp__export:
    dd hndllexport - IMAGEBASE
    dd 0
_d


msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

hnprintf:
    dw 0
    db 'printf', 0

msvcrt.dll db 'msvcrt.dll', 0

kernel32.dll db 'kernel32.dll', 0
dll.dll db 'dllnegep.dll', 0
_d

align FILEALIGN, db 0

