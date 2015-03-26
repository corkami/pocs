; PE with TLS but only imports to k32

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    inc dword [EPcounter]
    retn
_c

tls:
    inc dword [TLScounter]
    cmp dword [TLScounter], 1
    jb do_nothing

    push dword [TLScounter]
    push dword [EPcounter]
    push Msg
    call loadimports
    call eax
    add esp, 3 * 4
do_nothing:
    retn
_c

loadimports:
    push msvcrt.dll
    call [__imp__LoadLibraryA]
    push szprintf
    push eax
    call [__imp__GetProcAddress]
    retn
_c

TLScounter dd 0
EPcounter dd 0

Msg db " * TLS with only kernel32 import (%i EP execution, %i TLS execution(s))", 0ah, 0

msvcrt.dll db 'msvcrt.dll', 0
szprintf db 'printf', 0
_d

Import_Descriptor: ;*************************************************************
_import_descriptor kernel32.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend

_d

kernel32.dll_hintnames:
    dd hnLoadLibraryA - IMAGEBASE
    dd hnGetProcAddress - IMAGEBASE
    dd 0
_d

hnLoadLibraryA:
    dw 0
    db 'LoadLibraryA', 0
_d

hnGetProcAddress:
    dw 0
    db 'GetProcAddress', 0
_d

kernel32.dll_iat:
__imp__LoadLibraryA:
    dd hnLoadLibraryA - IMAGEBASE
__imp__GetProcAddress:
    dd hnGetProcAddress - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0

Image_Tls_Directory32: ;********************************************************
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,     dd AddressOfIndex
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks, dd CallBacks
iend
_d

AddressOfIndex dd 012345h

CallBacks:
    dd tls
    dd 0
_d

align FILEALIGN, db 0

