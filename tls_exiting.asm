; TLS PE with ExitProcess call
; the EntryPoint code is not called even though the TLS is called again after...

; Ange Albertini, BSD LICENCE 2011-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend

%include 'section_1fa.inc'

; this will never be executed
EntryPoint:
    push Exitproc
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c
Exitproc db "  # EntryPoint executed (unexpected !)", 0ah, 0
_d

tls:
    push TLSstart
    call [__imp__printf]
    add esp, 1 * 4
_
    mov dword [CallBacks], tls2
_
    push 0
    call [__imp__ExitProcess]
_c
TLSstart db " * exiting TLS:", 0ah, "  # 1st TLS call, ExitProcess() called", 0ah, 0
_d

tls2:
    push TLSEnd
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

TLSEnd db "  # 2nd TLS call", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

Image_Tls_Directory32:
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
