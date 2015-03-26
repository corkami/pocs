; a PE with fake .NET EntryPoint, imports but no COM directory

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,       dd Image_Tls_Directory32 - IMAGEBASE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 2 * FILEALIGN ; <=
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

;*******************************************************************************

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

next:
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

Msg db " * a PE with fake .NET EntryPoint, imports but no COM directory", 0ah, 0
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

EntryPoint:
    jmp [__imp__corexemain]


;*******************************************************************************

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd aMscoree_dll  - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd mscoree.dll_iat  - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend

hn_CoreExeMain db 0,0, '_CorExeMain',0
_d

mscoree.dll_iat:
__imp__corexemain:
    dd hn_CoreExeMain - IMAGEBASE
    dd 0
_d

aMscoree_dll db 'mscoree.dll',0
_d

;*******************************************************************************

tls:
    mov dword [__imp__corexemain], next
    retn

Image_Tls_Directory32:
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,     dd tls_aoi
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks, dd CallBacks
iend
_d

tls_aoi dd 0

CallBacks:
    dd tls
    dd 0
_d

align FILEALIGN, db 0
