; a PE without any data directory (loading imports manually)

; Ange Albertini, BSD LICENCE 2011-2013

%include 'consts.inc'

IMAGEBASE equ 0ffff0000h
org IMAGEBASE
bits 32

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
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 0
iend

%include 'section_1fa.inc'

EntryPoint:
    call $ + 5
base:
    pop ebp
    call LoadImports
    lea eax, [ebp - base + Msg]
    push eax
    call [ebp + ddprintf - base]
    add esp, 1 * 4
_
    push 0
    call [ebp + ddExitProcess - base]
_c

Msg db " * a PE with no DataDirectory (loading imports manually)", 0ah, 0
_d

;generated with api_hash.py
LOADLIBRARYA equ 06FFFE488h
EXITPROCESS equ 031678333h
PRINTF equ 09DDEF696h

LoadImports:

; Locate Kernel32.dll imagebase
    mov eax,[fs:030h]   ; _TIB.PebPtr
    mov eax,[eax + 0ch] ; _PEB.Ldr
    mov eax,[eax + 0ch] ; _PEB_LDR_DATA.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax + 18h] ; _LDR_MODULE.BaseAddress

;   brutal way, not as much compatible
;   mov eax, [esp + 4]
;   and eax, 0fff00000h

    mov [ebp + hKernel32 - base], eax

    mov eax, [ebp + hKernel32 - base]
    mov ebx, LOADLIBRARYA
    call GetProcAddress_Hash
    mov [ebp + ddLoadLibrary - base], ebx

    mov eax, [ebp + hKernel32 - base]
    mov ebx, EXITPROCESS
    call GetProcAddress_Hash
    mov [ebp + ddExitProcess - base], ebx

    lea eax, [szmsvcrt + ebp - base]
    push eax
    call [ebp + ddLoadLibrary - base]
    mov ebx, PRINTF
    call GetProcAddress_Hash
    mov [ebp + ddprintf - base], ebx

    retn
_c

szmsvcrt db "msvcrt", 0
_d

ddprintf dd 0
ddExitProcess dd 0
hKernel32 dd 0

ddLoadLibrary dd 0

%include 'gpa_ebp.inc'

align FILEALIGN, db 0
