; TLS PE where AddressOfIndex is used to patch a dword to 0

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend
%include 'section_1fa.inc'

EntryPoint:
AddressOfIndex equ $ + 1
    jmp long $
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
tls:
_c

Msg db " * TLS AddressOfIndex set to 0", 0ah, 0

_d
%include 'imports_printfexitprocess.inc'

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

