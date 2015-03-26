; file with extra fake TLS to disturb disassembly

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
tls2:
    push message
tls3:
    call [__imp__printf]
tls6:
    add esp, 1 * 4
tls4:
    push 0
tls5:
    call [__imp__ExitProcess]
tls:
_c

message db " * fake TLS callbacks for obfuscation", 0ah, 0
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
    dd tls2 + 1
    dd tls3 + 1
    dd tls4 + 1
    dd tls5 + 1
db "Que j'aime à faire apprendre un nombre utile aux sages !"
    dd 0
_d

align FILEALIGN, db 0
