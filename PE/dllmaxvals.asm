; a DLL with a maximal values in the headers

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 1000000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
  times 3Ah db -1
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
                at IMAGE_FILE_HEADER.TimeDateStamp,         dd -1
                at IMAGE_FILE_HEADER.PointerToSymbolTable,  dd -1
                at IMAGE_FILE_HEADER.NumberOfSymbols,       dd -1
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw 0DFFFh | IMAGE_FILE_DLL
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
            at IMAGE_OPTIONAL_HEADER32.MajorLinkerVersion,            db -1
            at IMAGE_OPTIONAL_HEADER32.MinorLinkerVersion,            db -1
            at IMAGE_OPTIONAL_HEADER32.SizeOfCode,                    dd -1
            at IMAGE_OPTIONAL_HEADER32.SizeOfInitializedData,         dd -1
            at IMAGE_OPTIONAL_HEADER32.SizeOfUninitializedData,       dd -1
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
            at IMAGE_OPTIONAL_HEADER32.BaseOfCode,                    dd -1
            at IMAGE_OPTIONAL_HEADER32.BaseOfData,                    dd -1
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
            at IMAGE_OPTIONAL_HEADER32.MajorOperatingSystemVersion,   dw -1
            at IMAGE_OPTIONAL_HEADER32.MinorOperatingSystemVersion,   dw -1
            at IMAGE_OPTIONAL_HEADER32.MajorImageVersion,             dw -1
            at IMAGE_OPTIONAL_HEADER32.MinorImageVersion,             dw -1
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 5 ; -1 would work until Windows 7
            at IMAGE_OPTIONAL_HEADER32.MinorSubsystemVersion,         dw -1
            at IMAGE_OPTIONAL_HEADER32.Win32VersionValue,             dd -1
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
            at IMAGE_OPTIONAL_HEADER32.CheckSum,                      dd -1
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw -1

       at IMAGE_OPTIONAL_HEADER32.DllCharacteristics,     dw 00ef7fh ; only AppContainer and enforce signature disabled

        at IMAGE_OPTIONAL_HEADER32.SizeOfStackReserve,    dd 0ffffffh
        at IMAGE_OPTIONAL_HEADER32.SizeOfStackCommit,     dd 1fffh
        at IMAGE_OPTIONAL_HEADER32.SizeOfHeapReserve,     dd 0ffffffh
        at IMAGE_OPTIONAL_HEADER32.SizeOfHeapCommit,      dd 1fffh
            at IMAGE_OPTIONAL_HEADER32.LoaderFlags,                   dd -1
            at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,           dd -1
iend


istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,  dd Exports_Directory - IMAGEBASE
        dd -1
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,        dd Import_Descriptor - IMAGEBASE, -1
    at IMAGE_DATA_DIRECTORY_16.ResourceVA,       dd 0, -1
        at IMAGE_DATA_DIRECTORY_16.Exception,        dd -1, -1
        at IMAGE_DATA_DIRECTORY_16.Security,         dd -1, -1
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
                                                     dd -1

    at IMAGE_DATA_DIRECTORY_16.DebugVA,          dd -1
    at IMAGE_DATA_DIRECTORY_16.DebugSize,        dd 0 ; prevent a fail under XP - don't ask :D
        at IMAGE_DATA_DIRECTORY_16.Description,      dd -1, -1
        at IMAGE_DATA_DIRECTORY_16.MIPS,             dd -1, -1

    at IMAGE_DATA_DIRECTORY_16.TLSVA,            dd 0, -1
    at IMAGE_DATA_DIRECTORY_16.Load,             dd 0, -1
    at IMAGE_DATA_DIRECTORY_16.BoundImportsVA,   dd 0, -1

    at IMAGE_DATA_DIRECTORY_16.IATVA,            dd 0, -1
        at IMAGE_DATA_DIRECTORY_16.DelayImportsVA,   dd -1, -1

    at IMAGE_DATA_DIRECTORY_16.COM,              dd 0, -1
        at IMAGE_DATA_DIRECTORY_16.reserved,         dd -1, -1
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    dd -1, -1
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    dd -1, -1, -1
    at IMAGE_SECTION_HEADER.Characteristics,  dd -1
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint: ;*******************************************************************
relocbase:
    cmp dword [esp + 8], DLL_PROCESS_ATTACH
    jz attached_

    push detach
    jmp print_

attached_:
    push attach
    jmp print_

print_:
    call [__imp__printf]
    add esp, 1 * 4
    retn 3 * 4
_c

__exp__Export:
    push export
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

attach db "  # DLL EntryPoint called on attach", 0ah, 0
detach db "  # DLL EntryPoint called on detach", 0ah, 0
export db "  # DLL export called", 0ah, 0
_d

Import_Descriptor: ;************************************************************
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd kernel32.dll_hintnames - IMAGEBASE
    dd -1, -1
    at IMAGE_IMPORT_DESCRIPTOR.Name1             , dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    dd -1, -1, -1
    at IMAGE_IMPORT_DESCRIPTOR.Name1             , dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
dd -1, -1, -1, -1
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd 0
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw -1
    db 'ExitProcess', 0
hnprintf:
    dw -1
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd -1 ; this is ok because there is a INT terminating

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

Exports_Directory: ;************************************************************
istruc IMAGE_EXPORT_DIRECTORY
     dd -1, -1, -1
  at IMAGE_EXPORT_DIRECTORY.nName,                 dd 0; can be -1 on >XP
     dd -1
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd NUMBER_OF_FUNCTIONS
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd NUMBER_OF_NAMES
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_name_ordinals - IMAGEBASE
iend

address_of_functions:
    dd __exp__Export - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd a__exp__Export - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4

address_of_name_ordinals:
    dw 0
_d

a__exp__Export:
db 'maxvals'
    db 0
_d

EXPORT_SIZE equ $ - Exports_Directory

Directory_Entry_Basereloc: ;****************************************************
block_start0:
    .VirtualAddress dd relocbase - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | 0xfff
    dw -1
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0
dummy:
    .VirtualAddress dd -1
    .SizeOfBlock dd -1
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | 0xffff
    dw -1

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc
align FILEALIGN, db 0
