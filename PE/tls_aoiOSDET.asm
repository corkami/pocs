; TLS PE where AddressOfIndex is used to patch turn an import descriptor to a terminator
; the OS' different behaviors will alterate imports loading

; Ange Albertini, BSD LICENCE 2011-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend
%include 'section_1fa.inc'


EntryPoint:
    mov eax, [__imp__MessageBoxA]
    cmp eax, hnMessageBoxA - IMAGEBASE
    jz W7
_
    push MsgXP
    jmp end_
_
W7:
    push MsgW7
end_:
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
tls:
_c

MsgW7 db " * TLS AoI => W7", 0ah, 0
MsgXP db " * TLS AoI => XP", 0ah, 0

_d

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
;user32.dll_DESCRIPTOR:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd user32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1             
        AddressOfIndex:
            dd user32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd user32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend

_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
user32.dll_hintnames:
    dd hnMessageBoxA - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnMessageBoxA:
    dw 0
    db 'MessageBoxA', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

user32.dll_iat:
__imp__MessageBoxA:
    dd hnMessageBoxA - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
user32.dll db 'user32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

Image_Tls_Directory32:
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,     dd AddressOfIndex
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks, dd CallBacks
iend
_d

CallBacks:
    dd tls
    dd 0
_d

align FILEALIGN, db 0
