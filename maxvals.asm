; a PE with a maximal values in the headers

; Ange Albertini, BSD LICENCE 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
  times 3Ah db -1
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
                at IMAGE_FILE_HEADER.TimeDateStamp        , dd -1
                at IMAGE_FILE_HEADER.PointerToSymbolTable , dd -1
                at IMAGE_FILE_HEADER.NumberOfSymbols      , dd -1
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw 0DFFFh
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
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
            at IMAGE_OPTIONAL_HEADER32.MinorSubsystemVersion,         dw -1
            at IMAGE_OPTIONAL_HEADER32.Win32VersionValue,             dd -1
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
            at IMAGE_OPTIONAL_HEADER32.CheckSum,                      dd -1
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI

       at IMAGE_OPTIONAL_HEADER32.DllCharacteristics,        dw 0fa7fh

        at IMAGE_OPTIONAL_HEADER32.SizeOfStackReserve,        dd 0ffffffh
        at IMAGE_OPTIONAL_HEADER32.SizeOfStackCommit,         dd 1fffh
        at IMAGE_OPTIONAL_HEADER32.SizeOfHeapReserve,         dd 0ffffffh
        at IMAGE_OPTIONAL_HEADER32.SizeOfHeapCommit,          dd 1fffh
            at IMAGE_OPTIONAL_HEADER32.LoaderFlags,               dd -1
            at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd -1
iend

istruc IMAGE_DATA_DIRECTORY_16
        at IMAGE_DATA_DIRECTORY_16.ExportsVA,        dd -1, -1
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,        dd Import_Descriptor - IMAGEBASE, -1
    at IMAGE_DATA_DIRECTORY_16.ResourceVA,       dd 0, -1
        at IMAGE_DATA_DIRECTORY_16.Exception,        dd -1, -1
        at IMAGE_DATA_DIRECTORY_16.Security,         dd -1, -1
        at IMAGE_DATA_DIRECTORY_16.FixupsVA,         dd -1, -1

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

EntryPoint:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * a PE with a maximal values in the headers", 0ah, 0
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
