; PE with TLS updating on-the-fly the callback list

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    push 0
    call [__imp__ExitProcess]
_c

tls:
    push adding2nd
    call printf
    add esp, 1 * 4
    mov dword [CallBacks + 4], tls2
    retn
_c

tls2:
    push tls2executing
    call printf
    add esp, 1 * 4
    mov dword [CallBacks], 0
    retn
_c

printf:
    jmp [__imp__printf]
_c


adding2nd     db ' * TLS on the fly update started', 0ah
              db '  # adding 2nd TLS to callbacks', 0ah, 0
tls2executing db '  # 2nd TLS executed. removing all TLS from callbacks to prevent further executions', 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

Image_Tls_Directory32:
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.StartAddressOfRawData, dd some_values
    at IMAGE_TLS_DIRECTORY32.EndAddressOfRawData,   dd some_values + 4
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,        dd some_values + 8
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks,    dd CallBacks
    at IMAGE_TLS_DIRECTORY32.SizeOfZeroFill,        dd some_values + 0ch
iend
_d

some_values dd 0, 0, 0, 0

CallBacks:
    dd tls
    dd 0
    dd 0
_d

align FILEALIGN, db 0

