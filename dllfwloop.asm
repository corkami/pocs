; forwarding DLL with forwarding loop

; Ange Albertini, BSD LICENCE 2009-2011

%include 'consts.inc'

IMAGEBASE equ 1000000h
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
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL
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
    at IMAGE_DATA_DIRECTORY_16.ExportsSize,  dd EXPORTS_SIZE    ; exports size is *REQUIRED* in this case
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
Section0Start:
section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    push 1
    pop eax
    retn 3 * 4
_c

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd 0
  Base                  dd 0
  NumberOfFunctions     dd NUMBER_OF_FUNCTIONS
  NumberOfNames         dd NUMBER_OF_NAMES
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_name_ordinals - IMAGEBASE
_d

address_of_functions:
    dd adllfwloop_loophere  - IMAGEBASE
    dd adllfwloop_looponceagain  - IMAGEBASE
    dd amsvcrt_printf - IMAGEBASE
    dd adllfwloop_GroundHogDay - IMAGEBASE
    dd adllfwloop_Yang - IMAGEBASE
    dd adllfwloop_Ying - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd a__exp__ExitProcess - IMAGEBASE
    dd a__exp__LoopHere - IMAGEBASE
    dd a__exp__LoopOnceAgain - IMAGEBASE
    dd a__exp__GroundHogDay - IMAGEBASE
    dd a__exp__Ying - IMAGEBASE
    dd a__exp__Yang - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4
_d

adllfwloop_loophere db 'dllfwloop.LoopHere', 0
adllfwloop_looponceagain db 'dllfwloop.LoopOnceAgain', 0
amsvcrt_printf db "msvcrt.printf", 0
adllfwloop_GroundHogDay db 'dllfwloop.GroundHogDay', 0
adllfwloop_Ying db 'dllfwloop.Ying', 0
adllfwloop_Yang db 'dllfwloop.Yang', 0

_d

address_of_name_ordinals:
    dw 0, 1, 2, 3, 4, 5
_d

a__exp__ExitProcess db 'ExitProcess', 0
a__exp__LoopHere db 'LoopHere', 0
a__exp__LoopOnceAgain db 'LoopOnceAgain', 0
a__exp__GroundHogDay db 'GroundHogDay', 0
a__exp__Ying db 'Ying', 0
a__exp__Yang db 'Yang', 0

_d

EXPORTS_SIZE equ $ - Exports_Directory

align FILEALIGN, db 0
SIZEOFIMAGE equ $ - IMAGEBASE
Section0Size equ $ - Section0Start