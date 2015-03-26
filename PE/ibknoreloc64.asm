; a PE32+ with kernel imagebase and RIP-relative code (no relocations)

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

IMAGEBASE equ 0ffffffffffff0000h ; <===
org IMAGEBASE
bits 64

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_AMD64
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER64
    at IMAGE_OPTIONAL_HEADER64.Magic,                 dw IMAGE_NT_OPTIONAL_HDR64_MAGIC
    at IMAGE_OPTIONAL_HEADER64.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.ImageBase,             dq IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER64.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER64.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER64.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER64.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    sub rsp, 8 * 5
    lea ecx, [rel Msg] ; <==
    call [rel __imp__printf]
    xor ecx, ecx
    call [rel __imp__ExitProcess]
_c

Msg db " * kernel IB + RIP-relative code (PE32+)", 0ah, 0
_d

%include 'imports_printfexitprocess64.inc'

align FILEALIGN, db 0
