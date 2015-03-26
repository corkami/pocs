; imports with Windows 7 redirection via apisetschema.dll
; documented by deroko @ http://xchg.info/wiki/index.php?title=ApiMapSet

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * api-ms-* redirection (Windows7)", 0ah, 0
_d

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
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


kernel32.dll db 'API-MS-Win-Core-Localization-L1-1-0.dll', 0 ; <===
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0

