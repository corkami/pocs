; PE with its own exports, used to store data, restored on imports resolving

; Ange Albertini, BSD LICENCE 2009-2011

%include 'consts.inc'


IMAGEBASE equ 10000000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
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
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,  dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd import_descriptor - IMAGEBASE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN
EntryPoint:
ownexports.exe_iat:
    dd 80000000h ; => dd 000101468h => 68 14100010   push 10001014
    dd 80000001h ; => dd 04015FF10h => FF15 40100010 call [10001040]
    dd 80000002h ; => dd 083100010h => 83C4 04       add esp,4
    dd 80000003h ; => dd 0CCC304C4h => C3            retn
    dd 0

export db " * data stored as fake export table", 0ah, 0
_d

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0

import_descriptor:
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0
    dd 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;ownexports.exe_DESCRIPTOR:
    dd ownexports.exe_iat - IMAGEBASE
    dd 0
    dd 0
    dd ownexports.exe - IMAGEBASE
    dd ownexports.exe_iat - IMAGEBASE

    times 5 dd 0

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

hnprintf:
    dw 0
    db 'printf', 0

msvcrt.dll db 'msvcrt.dll', 0
ownexports.exe db 'exportsdata.exe', 0

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd 0
  Base                  dd 0
  NumberOfFunctions     dd NBFUNCTIONS
  NumberOfNames         dd 0
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd 0
  AddressOfNameOrdinals dd address_of_ordinals - IMAGEBASE
_d

address_of_functions:
dd 000101468h - IMAGEBASE  ; 68 14100010   push 10001014
dd 04015FF10h - IMAGEBASE  ; FF15 40100010 call [10001040]
dd 083100010h - IMAGEBASE  ; 83C4 04       add esp,4
dd 0CCC304C4h - IMAGEBASE  ; C3            retn
NBFUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_ordinals:
  dw 0,1,2,3

align FILEALIGN, db 0
