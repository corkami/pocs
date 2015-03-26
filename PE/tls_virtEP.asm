; a PE with a random EntryPoint, and the TLS just allocates virtual space before it's called

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'
EntryPoint equ 50000h

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend

%include 'section_1fa.inc'

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
    push EntryPoint       ; LPVOID lpAddress
    call [__imp__VirtualAlloc]
_
    mov edi, EntryPoint
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
lpEntryPoint dd EntryPoint
_d

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
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

Image_Tls_Directory32: ;********************************************************
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,     dd TlsIndex
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks, dd CallBacks
iend
_d

TlsIndex dd 012345h

CallBacks:
    dd tls
    dd 0
_d

align FILEALIGN, db 0

