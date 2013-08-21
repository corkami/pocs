; PE with
; * a kernel range IMAGEBASE to force predictable relocations
; * and low alignment to make header writeable

; => relocation is applied to e_lfanew in memory
; another PE header is then pointed to, 
;   but on XP, imports are relocated before so this 2nd DD is not used for imports
; this would fail under Windows 7

; trick suggested by Peter Ferrie

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 0FFFF0000h

org IMAGEBASE
bits 32

SECTIONALIGN equ 800h
FILEALIGN equ SECTIONALIGN

start:
istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
    lfanew:
iend

NT_Headers:
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
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd RealImports - IMAGEBASE, -1 ; not required
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE

iend
SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 20000h
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 20000h
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align FILEALIGN, db 0

SIZEOFHEADERS equ $ - IMAGEBASE

EntryPoint:
reloc01:
    push msg
reloc22:
    call [__imp__printf]
    add esp, 1 * 4
    push 0
reloc42:
    call [__imp__ExitProcess]
_c

msg db " * relocated e_lfanew with dual (+unused) PE headers and DataDirectory (XP)", 0ah, 0
_d


FakeImports: ;******************************************************************
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd FAKE.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd fake_iat1 - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd FAKE2.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd fake_iat2 - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

RealImports:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd msvcrt2.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d
hnyouradd:
    dw 0
    db 'YOUR AD', 0
_d
hnhere:
    dw 0
    db 'HERE', 0
_d

fake_iat1:
    dd hnyouradd  - IMAGEBASE
    dd 0
fake_iat2:
    dd hnhere  - IMAGEBASE
    dd 0

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
msvcrt2.dll db 'msvcrt.dll', 0
FAKE.dll db 'HI', 0
FAKE2.dll db 'MUM', 0
_d

Directory_Entry_Basereloc: ;****************************************************

block_start0:
    .VirtualAddress dd reloc01 - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc22 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - reloc01)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0
block_start1:
    .VirtualAddress dd lfanew - 4 - start
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK1
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | 0
BASE_RELOC_SIZE_OF_BLOCK1 equ $ - block_start1

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0

;*******************************************************************************

; need to apply a delta 0f 20000 for 2nd PE header
align 10000h, db 0
db 0
align 10000h, db 0

istruc IMAGE_DOS_HEADER ; easy alignment ;)
iend
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0 ; required to validate 2nd header
iend
istruc IMAGE_FILE_HEADER
;    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386 ; not required :D
iend

istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC ; required AGAIN ?
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI   ; required for console
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 2
iend

istruc IMAGE_DATA_DIRECTORY_16
iend

align FILEALIGN, db 0

SIZEOFIMAGE EQU $ - IMAGEBASE
