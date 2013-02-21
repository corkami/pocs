; a PE with a resource, loaded by name

; Ange Albertini, BSD LICENCE 2009-2011

%include 'consts.inc'

IMAGEBASE equ 400000h

SOME_TYPE equ 315h
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

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceVA, dd Directory_Entry_Resource - IMAGEBASE
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
    push arestype               ; lpType
    push aresname               ; lpName
    push 0                      ; hModule
    call [__imp__FindResourceA]
_
    push eax
    push 0                      ; hModule
    call [__imp__LoadResource]
_
    push eax
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

aresname db 'RES', 0
arestype db 'TYPE', 0
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
    dd hnFindResourceA - IMAGEBASE
    dd hnLoadResource - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnFindResourceA:
    dw 0
    db 'FindResourceA', 0
hnLoadResource:
    dw 0
    db 'LoadResource', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__FindResourceA:
    dd hnFindResourceA - IMAGEBASE
__imp__LoadResource:
    dd hnLoadResource  - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d
_d

; root directory
Directory_Entry_Resource:
resource_directory:
    .Characteristics      dd 0
    .TimeDateStamp        dd 0
    .MajorVersion         dw 0
    .MinorVersion         dw 0
    .NumberOfNamedEntries dw 1
    .NumberOfIdEntries    dw 0

IMAGE_RESOURCE_DIRECTORY_ENTRY_1:
    .ID dd (1 << 31) | (alrestype - resource_directory)    ; .. resource type of that directory
    .OffsetToData dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_directory_type_rcdata - resource_directory)

; type subdirectory
resource_directory_type_rcdata:
    .Characteristics      dd 0
    .TimeDateStamp        dd 0
    .MajorVersion         dw 0
    .MinorVersion         dw 0
    .NumberOfNamedEntries dw 1
    .NumberOfIdEntries    dw 0
IMAGE_RESOURCE_DIRECTORY_ENTRY_01:
    .ID dd (1 << 31) | (alresname - resource_directory)  ; name of the underneath resource
    .OffsetToData dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_directory_languages0 - resource_directory)

; resource subdirectory
resource_directory_languages0:
    .Characteristics      dd 0
    .TimeDateStamp        dd 0
    .MajorVersion         dw 0
    .MinorVersion         dw 0
    .NumberOfNamedEntries dw 0
    .NumberOfIdEntries    dw 1
IMAGE_RESOURCE_DIRECTORY_ENTRY_001:
    .ID dd 0
    .OffsetToData dd IMAGE_RESOURCE_DATA_ENTRY_101 - resource_directory

IMAGE_RESOURCE_DATA_ENTRY_101:
    OffsetToData dd resource_data - IMAGEBASE
    Size1 dd        RESOURCE_SIZE
    CodePage dd     0
    Reserved dd     0

align 4, db 0

; length + widestring
alresname dw 3, "R", "E", "S", 0
alrestype dw 4, "T", "Y", "P", "E", 0

resource_data:
Msg db " * resource loaded by 'named' name and type", 0ah, 0
RESOURCE_SIZE equ $ - resource_data
_d

align FILEALIGN, db 0
