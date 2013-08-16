; a PE32+ enabling LoaderSnaps via its LoadConfig DataDirectory

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 64

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
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
    at IMAGE_DATA_DIRECTORY_16.Load,      dd LoadConfig - IMAGEBASE, LOADCONFIGSIZE
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

EntryPoint: ;*******************************************************************
    sub rsp, 8 * 5
    call [__imp__RtlGetNtGlobalFlags]
    mov edx, eax
    and eax, 2
    jz error_

    lea ecx, [Msg]
    call [__imp__printf]
_
error_:
    xor ecx, ecx
    call [__imp__ExitProcess]
_c

Msg db " * a PE32+ enabling LoaderSnaps via its LoadConfig DataDirectory (GlobalFlags: %08X)", 0ah, 0
_d

LoadConfig: ;*******************************************************************

istruc IMAGE_LOAD_CONFIG_DIRECTORY64
    at IMAGE_LOAD_CONFIG_DIRECTORY64.Size,           dd IMAGE_LOAD_CONFIG_DIRECTORY64_size
    at IMAGE_LOAD_CONFIG_DIRECTORY64.GlobalFlagsSet, dd FLG_SHOW_LDR_SNAPS
iend

LOADCONFIGSIZE equ $ - LoadConfig

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
_import_descriptor ntdll.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend


kernel32.dll_hintnames dq hnExitProcess - IMAGEBASE, 0
ntdll.dll_hintnames    dq hnRtlGetNtGlobalFlags - IMAGEBASE, 0
msvcrt.dll_hintnames   dq hnprintf - IMAGEBASE, 0

kernel32.dll_iat:
__imp__ExitProcess dd hnExitProcess - IMAGEBASE, 0

msvcrt.dll_iat:
__imp__printf dd hnprintf - IMAGEBASE, 0

ntdll.dll_iat:
__imp__RtlGetNtGlobalFlags dd hnRtlGetNtGlobalFlags - IMAGEBASE, 0

hnExitProcess         db 0,0, 'ExitProcess', 0
hnRtlGetNtGlobalFlags db 0,0, 'RtlGetNtGlobalFlags', 0
hnprintf              db 0,0, 'printf', 0

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
ntdll.dll db 'ntdll.dll', 0
_d

align FILEALIGN, db 0
