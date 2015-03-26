; a PE32+ with TLS

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers64.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd tls - IMAGEBASE
iend

%include 'section_1fa.inc'

callback:
    sub rsp, 5 * 8
    lea ecx, [TlsMsg]
    call [__imp__printf]
    retn 3 * 8
    
EntryPoint:
    sub rsp, 5 * 8
    lea ecx, [Msg]
    call [__imp__printf]
    xor ecx, ecx
    call [__imp__ExitProcess]
_c

Msg db " * a standard PE32+ with TLS", 0ah, 0
TlsMsg db " - callback called", 0ah, 0
_d

;*******************************************************************************
Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dq hnExitProcess - IMAGEBASE
    dq 0
msvcrt.dll_hintnames:
    dq hnprintf - IMAGEBASE
    dq 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
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

;*******************************************************************************

tls:
istruc IMAGE_TLS_DIRECTORY64
    at IMAGE_TLS_DIRECTORY64.AddressOfIndex,     dq TlsIndex
    at IMAGE_TLS_DIRECTORY64.AddressOfCallBacks, dq CallBacks
iend
_d

TlsIndex dq 0

CallBacks:
    dq callback
    dq 0


align FILEALIGN, db 0
