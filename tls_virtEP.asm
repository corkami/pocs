; a PE with a random EntryPoint, and the TLS just allocates virtual space before it's called

; Ange Albertini, BSD LICENCE 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
ENTRYPOINT equ 50000h
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
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd ENTRYPOINT - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,       dd Image_Tls_Directory32 - IMAGEBASE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

SIZEOFHEADERS equ $ - IMAGEBASE
section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN
Section0Start:
_c
next:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess]
_c

tls:
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push 1000h              ; SIZE_T dwSize
    push ENTRYPOINT       ; LPVOID lpAddress
    call [__imp__VirtualAlloc]
_
    mov edi, ENTRYPOINT
    mov al, 68h
    stosb
    mov eax, next
    stosd
    mov al, 0c3h
    stosb
_
    retn
_c

Msg db " * virtual entrypoint executed", 0ah, 0
lpEntryPoint dd ENTRYPOINT
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
    dd hnVirtualAlloc - IMAGEBASE
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnVirtualAlloc:
    dw 0
    db 'VirtualAlloc', 0
hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__VirtualAlloc:
    dd hnVirtualAlloc - IMAGEBASE
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

Image_Tls_Directory32:
    StartAddressOfRawData dd 0
    EndAddressOfRawData   dd 0
    AddressOfIndex        dd some_value
    AddressOfCallBacks    dd CallBacks
    SizeOfZeroFill        dd 0
    Characteristics       dd 0
_d

some_value dd 012345h

CallBacks:
    dd tls
    dd 0
_d

align FILEALIGN, db 0

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE
