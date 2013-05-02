; a 64b PE using an Exception directory

; Ange Albertini, BSD LICENCE 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 64

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
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_AMD64
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER64
    at IMAGE_OPTIONAL_HEADER64.Magic,                 dw IMAGE_NT_OPTIONAL_HDR64_MAGIC
    at IMAGE_OPTIONAL_HEADER64.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER64.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER64.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER64.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER64.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Imports - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Exception, dd Exception - IMAGEBASE, EXCEPTION_SIZE
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

handler:
    lea ecx, [Msg]
    call [__imp__printf]
    xor ecx, ecx
    call [__imp__ExitProcess]
_c

Msg db " * a 64b PE making use of an Exception DataDirectory", 0ah, 0
_d

EntryPoint:
    sub rsp, 8 * 5
    int3
EndCode:

Imports: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend

_d

hnExitProcess
    dw 0
    db 'ExitProcess', 0

hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dq hnExitProcess - IMAGEBASE
    dq 0

msvcrt.dll_iat:
__imp__printf:
    dq hnprintf - IMAGEBASE
    dq 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align 4, db 0

Exception: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
istruc RUNTIME_FUNCTION
    at RUNTIME_FUNCTION.FunctionStart, dd EntryPoint - IMAGEBASE
    at RUNTIME_FUNCTION.FunctionEnd  , dd EndCode - IMAGEBASE
    at RUNTIME_FUNCTION.UnwindInfo   , dd UnwindData - IMAGEBASE
iend
EXCEPTION_SIZE equ $ - Exception

UnwindData:
istruc UNWIND_INFO
    at UNWIND_INFO.Ver3_Flags     , db 1 + (UNW_FLAG_EHANDLER << 3)
    at UNWIND_INFO.CntUnwindCodes , db 0 ; let's shrink it to the minimum
iend
align 4, db 0
    dd handler - IMAGEBASE ; 1 exception handler
    dd 0                   ; handler data

align FILEALIGN, db 0
