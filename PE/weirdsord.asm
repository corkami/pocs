; a PE where 4K is read from the section for no apparent reason
; pointed out by Peter Ferrie

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 40000h
FILEALIGN equ 4000h

DELTA equ SECTIONALIGN - 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
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
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd SECTIONALIGN ; Bug in Yasm
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE + DELTA
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 10eh
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 201h
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

align 200h, db 0
EntryPoint:
    mov esi, end_ + DELTA
    lodsd
    cmp eax, " END"
    jnz no_msg
_
    lodsd
    cmp eax, "FAKE"
    jz no_msg

    push Msg + DELTA
    call [__imp__printf + DELTA]
    add esp, 1 * 4
_
no_msg:
    push 0
    call [__imp__ExitProcess + DELTA]
_c

Msg db " * a PE with weird SORD (expected size found)", 0ah, 0
_d

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk , dd DELTA + kernel32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1              , dd DELTA + kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk         , dd DELTA + kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk , dd DELTA + msvcrt.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1              , dd DELTA + msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk         , dd DELTA + msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend

_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE + DELTA
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE + DELTA
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
    dd hnExitProcess - IMAGEBASE + DELTA
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE + DELTA
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d
times $ + 1000h - 240h - 4 - EntryPoint db 0
end_:
db " END"
db "FAKE"
times 5 dd 0
