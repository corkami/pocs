; PE corrupting registers as much as possible, during TLS and EP

; Ange Albertini, BSD LICENCE 2011-2013

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
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 2 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

SIZEOFHEADERS equ $ - IMAGEBASE
section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

randw:
    mov eax, dword [key]
    imul eax, eax, 0x343FD
    add eax, 0x269EC3
    ror eax,0x10
    mov dword [key], eax
    retn

randreg:
    call randw
    mov esi, eax
    call randw
    mov edi, eax
    call randw
    mov ebx, eax
    call randw
    mov ecx, eax
    call randw
    mov edx, eax
    call randw
    mov ebp, eax
    retn

EntryPoint:
    push afakeregslibdll
    call [__imp__loadlibrarya]
    push Msg
    call printf
    add esp, 1 * 4

    call randreg
    xor eax, edx
    retn
_c
afakeregslibdll dd 'fakeregslib.dll', 0

ret_ dd 0
saved_reg dd 0
key dd 0

align 20h db 0
tls:
    mov dword [CallBacks], 0
    pop dword [ret_]
    mov dword [saved_reg], esi
    rdtsc
    mov dword [key], eax

    call randreg
    call randw
    mov esp, eax
    xor esp, edx
    mov esi, dword [saved_reg]
    jmp dword [ret_]

printf:
    jmp [__imp__printf]
_c

Msg dd " * corrupted registers on TLS and Exit return", 0ah, 0

_d

;*******************************************************************************

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnLoadLibraryA - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnLoadLibraryA:
    dw 0
    db 'LoadLibraryA', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__loadlibrarya:
    dd hnLoadLibraryA - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

;*******************************************************************************

Image_Tls_Directory32:
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,     dd Index
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks, dd CallBacks
iend
_d

Index dd 012345h

CallBacks:
    dd tls
    dd 0
_d

align FILEALIGN, db 0

