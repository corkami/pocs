; a PE with code and no sections, no EntryPoint, no imports

;Ange Albertini, BSD Licence, 2012-2013

%include 'consts.inc'

IMAGEBASE equ 1000000h

org IMAGEBASE
bits 32

DOS_HEADER:
.e_magic dw 'MZ'

align 4, db 0

istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,          dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections, dw 0
    at IMAGE_FILE_HEADER.Characteristics,  dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL
iend

istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd 0F976543h
    at IMAGE_OPTIONAL_HEADER32.BaseOfCode,            dd 0 ; must be valid for W7
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd 4 ; also sets e_lfanew
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd 4
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFIMAGE - 1
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             db IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 13
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA, dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd 0
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend


Image_Tls_Directory32:
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,     dd Image_Tls_Directory32
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks, dd $ + 4
                                                 dd TLS
iend

;*******************************************************************************

__exp__Export:
	hlt
TLS:
    call LoadImports
    push Msg
    call [ddprintf]
    add esp, 1 * 4
	retn
_c

Msg db " * a PE with working code yet no sections, no EntryPoint, no imports", 0ah, 0
_d

;*******************************************************************************
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

    mov [hKernel32], eax

    mov eax, [hKernel32]
    mov ebx, LOADLIBRARYA
    call GetProcAddress_Hash
    mov [ddLoadLibrary], ebx

    mov eax, [hKernel32]
    mov ebx, EXITPROCESS
    call GetProcAddress_Hash
    mov [ddExitProcess], ebx

    push szmsvcrt
    call [ddLoadLibrary]
    mov ebx, PRINTF
    call GetProcAddress_Hash
    mov [ddprintf], ebx

    retn
_c

szmsvcrt db "msvcrt.dll", 0
_d

ddprintf dd 0
ddExitProcess dd 0
hKernel32 dd 0

ddLoadLibrary dd 0

%include 'gpa.inc'

;*******************************************************************************

Exports_Directory:
istruc IMAGE_EXPORT_DIRECTORY
    at IMAGE_EXPORT_DIRECTORY.nName,                 dd aDllName - IMAGEBASE
    at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd NUMBER_OF_FUNCTIONS
    at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd NUMBER_OF_NAMES
    at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
    at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
    at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_name_ordinals - IMAGEBASE
iend
_d

aDllName db 'nothing.dll', 0
_d

address_of_functions:
    dd __exp__Export - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd a__exp__Export - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4

_d
address_of_name_ordinals:
    dw 0
_d

a__exp__Export:
db 'export'
    db 0
_d

EXPORT_SIZE equ $ - Exports_Directory

;*******************************************************************************

SIZEOFIMAGE equ $ - IMAGEBASE
