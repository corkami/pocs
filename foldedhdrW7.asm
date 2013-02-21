; a PE where the NT headers is partially overwritten by section space,
; as if the sections were folded back on the header.
; this W7 only version has a much smaller SizeOfHeaders

; neat original idea by ReversingLabs

; Ange Albertini, BSD LICENCE 2011

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE - (SECTIONALIGN - FILEALIGN)
iend


section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

;---------------------------------------------- CUT and FOLD here ----------------------------------

; ok here we're at RVA 1000h (start of 1st section),
; so this data will overwrite the PE headers originally loaded from offset F80h, physically further in the file.

dd Import_Descriptor - IMAGEBASE, 0
times 14 dd 0,0

istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend

EntryPoint:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * PE header overwritten on loading (W7)", 0ah, 0
_d

Import_Descriptor:
;kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0

times 0f80h - FILEALIGN * 2 db 0 ; to make the header overlap on address offset/rva 1000h

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend

istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw 0e0h
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd 1
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
dd 88660001h,010009988h
;---------------------------------------------- CUT and FOLD here ----------------------------------
; we cut the header here, and we're right at offset 1000h
;---------------------------------------------- CUT and FOLD here ----------------------------------

dd 86600010h,001000998h
dd 66000100h,000100099h
dd 6000100Fh,0F0010009h
dd 000100FFh,0FF001000h
dd 00100FF0h,00FF00100h
dd 0100FF05h,020FF0010h
dd 100FF055h,0220FF001h
dd 100FF055h,0220FF001h
dd 0100FF05h,020FF0010h
dd 00100FF0h,00FF00100h
dd 000100FFh,0FF001000h
dd 6000100Fh,0F0010009h
dd 66000100h,000100099h
dd 86600010h,001000998h
dd 88660001h,010009988h
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
; we still need realistic values here to get the PE validated and loaded
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1
    at IMAGE_SECTION_HEADER.PointerToRawData, dd FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
