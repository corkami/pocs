; simple TLS PE
; displays twice under XP, once under W7

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    mov dword [TLSMsg], TLSEnd
    push Exitproc
    call printf
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess]
_c

tls:
    push dword [TLSMsg]
    call printf
    add esp, 1 * 4
    retn
_c

printf:
    jmp [__imp__printf]
_c

TLSMsg dd TLSstart
TLSstart db " * simple TLS:", 0ah, "  # 1st TLS call", 0ah, 0
TLSEnd db "  # 2nd TLS call", 0ah, 0
Exitproc db "  # EntryPoint executed", 0ah, "  # ExitProcess called", 0ah, 0

_d

%include 'imports_printfexitprocess.inc'

Image_Tls_Directory32:
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

