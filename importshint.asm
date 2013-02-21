; PE with exports with the same name - and the right one is called via hints

; Ange Albertini, BSD LICENCE 2009-2011

%include 'consts.inc'


IMAGEBASE equ 400000h
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
    jmp [__imp__export]
_c

FakeExport:
    push afakeexport
    call [__imp__printf]
    add esp, 1 * 4
    retn
FakeExport2:
_c

afakeexport db " * ERROR - incorrect import called (hint ignored ?)", 0ah, 0
_d

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
importhints.exe_iat:
__imp__export:
    dd hnexport - IMAGEBASE
    dd 0
_d

import_descriptor:
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0
    dd 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;importhints.exe_DESCRIPTOR:
    dd importhints.exe_hintnames - IMAGEBASE
    dd 0
    dd 0
    dd importhints.exe - IMAGEBASE
    dd importhints.exe_iat - IMAGEBASE

    times 5 dd 0

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

importhints.exe_hintnames:
    dd hnexport - IMAGEBASE
    dd 0

hnprintf:
    dw 0
    db 'printf', 0
_d

msvcrt.dll db 'msvcrt.dll', 0
importhints.exe db 'importshint.exe', 0
_d

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd 0
  Base                  dd 0
  NumberOfFunctions     dd 4
  NumberOfNames         dd 4
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_ordinals - IMAGEBASE
_d

address_of_functions:
    dd FakeExport - IMAGEBASE
    dd FakeExport2 - IMAGEBASE
    dd GoodExport - IMAGEBASE
    dd FakeExport - IMAGEBASE
_d

address_of_names:
 dd hnexport + 2 - IMAGEBASE
 dd someothername - IMAGEBASE
 dd hnexport + 2 - IMAGEBASE
 dd hnexport + 2 - IMAGEBASE


someothername db 'export:    CC   oops I did it again...      ', 0
_d
address_of_ordinals dw 0, 1, 2, 3

hnexport:
    dw 2 ; <== here is the hint that gives the loader the starting position in the address_of_functions array
    db 'export', 0
_d

GoodExport:
    push agoodexport
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

agoodexport db " * correct import called via hinting", 0ah, 0
_d

align FILEALIGN, db 0
