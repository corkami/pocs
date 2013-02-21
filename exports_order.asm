; a PE with exports not alphabetically sorted

; Ange Albertini, BSD LICENCE 2013

; Explanation:

; exports appearance in AddressOfNames should be alphabetically sorted: A < B < ...a < b ...
; here, the table is, in this order: export, zz, export2
; resolving manually 'export' will work because it's first.
; resolving manually 'export2' will fail because it's after 'zz', thus the loader
; will assume it can't be found.

; check LdrpNameToOrdinal (ReactOS or ntdll) for more information.

;*******************************************************************************

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
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
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

;*******************************************************************************

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    push ownexports.exe
    call [__imp__LoadLibraryA]
    mov [h], eax
_
    push a_export
    push eax
    call [__imp__GetProcAddress]
    jmp eax
_c

export_add:
    push a_export2
    mov eax, [h]
    push eax
    call [__imp__GetProcAddress] ; we assume EAX==0 because it should fail
    add eax, end_ - 07fh         ; expected error code: 7fh
    mov ebx, [fs:18h]
    add eax, [ebx + 34h]
    jmp eax
_c

end_:
    push msg
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

msg db " * a PE with exports not lexicographically sorted", 0ah, 0
h dd 0
_d

;*******************************************************************************
import_descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_iat:
__imp__LoadLibraryA:
    dd hnLoadLibraryA - IMAGEBASE
__imp__GetProcAddress:
    dd hnGetProcAddress - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0

kernel32.dll_hintnames:
    dd hnLoadLibraryA - IMAGEBASE
    dd hnGetProcAddress - IMAGEBASE
    dd 0

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnLoadLibraryA:
    dw 0
    db 'LoadLibraryA', 0

hnGetProcAddress:
    dw 0
    db 'GetProcAddress', 0

hnprintf:
    dw 0
    db 'printf', 0
_d

msvcrt.dll db 'msvcrt.dll', 0
kernel32.dll db 'kernel32.dll', 0
ownexports.exe db 'exports_order.exe', 0

; ******************************************************************************

Exports_Directory:
istruc IMAGE_EXPORT_DIRECTORY
    at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions    , dd 3
    at IMAGE_EXPORT_DIRECTORY.NumberOfNames        , dd 3
    at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions   , dd address_of_functions - IMAGEBASE
    at IMAGE_EXPORT_DIRECTORY.AddressOfNames       , dd address_of_names - IMAGEBASE
    at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_ordinals - IMAGEBASE
iend
_d

address_of_functions:
    dd export_add + 0 - IMAGEBASE
    dd export_add + 1 - IMAGEBASE
    dd export_add + 2 - IMAGEBASE

address_of_names:
    dd a_export - IMAGEBASE
    dd a_zz - IMAGEBASE
    dd a_export2 - IMAGEBASE

address_of_ordinals dw 0, 2, 1 ; making them ordinally ordered, which doesn't help
_d

a_export db 'export', 0
a_zz db 'zz', 0
a_export2 db 'export2', 0

align FILEALIGN, db 0
