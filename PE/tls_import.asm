; TLS using an import IAT entry as callbacks 
; => API will be called with IMAGEBASE as parametersimple TLS PE
;  => WinExec can thus execute MZ.exe

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,     dd Image_Tls_Directory32 - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    mov dword [__imp__WinExec], 0 ; to prevent a 2nd execution
    push 0
    call [__imp__ExitProcess]
_c

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor gdi32.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnWinExec - IMAGEBASE
    dd 0
_d
gdi32.dll_hintnames:
    dd hnEngQueryEMFInfo - IMAGEBASE
    dd 0

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnWinExec:
    dw 0
    db 'WinExec', 0
hnEngQueryEMFInfo:
    dw 0
    db 'EngQueryEMFInfo', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__WinExec:
    dd hnWinExec - IMAGEBASE
    dd 0
    
gdi32.dll_iat:
__imp__EngQueryEMFInfo:
    dd hnEngQueryEMFInfo - IMAGEBASE
_d

kernel32.dll db 'kernel32.dll', 0
gdi32.dll db 'gdi32.dll', 0
_d

Image_Tls_Directory32:
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.StartAddressOfRawData, dd dummy
    at IMAGE_TLS_DIRECTORY32.EndAddressOfRawData,   dd dummy
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,        dd dummy
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks,    dd __imp__WinExec
    at IMAGE_TLS_DIRECTORY32.SizeOfZeroFill,        dd dummy
        dummy dd 0
iend
_d

align FILEALIGN, db 0

