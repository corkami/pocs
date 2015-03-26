; a PE32+ enabling LoaderSnaps via its LoadConfig DataDirectory

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers64.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Load,      dd LoadConfig - IMAGEBASE, LOADCONFIGSIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 2 * FILEALIGN
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
