; a DYNAMIC_BASE DLL loader

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 400000h
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
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 3
    at IMAGE_OPTIONAL_HEADER32.MinorSubsystemVersion,     dw 10
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
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
    inc dword [counter]
    cmp dword [counter], 9
    jz end_

    push aslr.dll
    call [__imp__LoadLibraryA]
    mov [h], eax

    push eax
    push msg
    call [__imp__printf]
    add esp, 2 * 4
_
    push dword [h]
    call [__imp__FreeLibrary]
    jmp EntryPoint
_
end_:
    push 0
    call [__imp__ExitProcess]
_c

msg db ' * DYNAMIC_BASE DLL loaded (ImageBase 0%08xh)', 0ah, 0
_d

h dd 0
exp dd 0
counter dd 0
_d

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnLoadLibraryA - IMAGEBASE
    dd hnFreeLibrary - IMAGEBASE
    dd hnGetProcAddress - IMAGEBASE
    dd 0
_d

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess    _IMAGE_IMPORT_BY_NAME 'ExitProcess'
hnprintf         _IMAGE_IMPORT_BY_NAME 'printf'
hnLoadLibraryA   _IMAGE_IMPORT_BY_NAME 'LoadLibraryA'
hnFreeLibrary    _IMAGE_IMPORT_BY_NAME 'FreeLibrary'
hnGetProcAddress _IMAGE_IMPORT_BY_NAME 'GetProcAddress'
_d

kernel32.dll_iat:
__imp__ExitProcess    dd hnExitProcess - IMAGEBASE
__imp__LoadLibraryA   dd hnLoadLibraryA - IMAGEBASE
__imp__FreeLibrary    dd hnFreeLibrary - IMAGEBASE
__imp__GetProcAddress dd hnGetProcAddress - IMAGEBASE
    dd 0
_d

msvcrt.dll_iat:
__imp__printf dd hnprintf - IMAGEBASE
    dd 0

msvcrt.dll db 'msvcrt.dll', 0
kernel32.dll db 'kernel32.dll', 0
aslr.dll db 'aslr.dll', 0
_d

align FILEALIGN, db 0

SIZEOFIMAGE EQU $ - IMAGEBASE
