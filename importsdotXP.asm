; a PE using trailing dots in its imports (XP only)

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * a PE using trailing dots in its imports (XP/W8 only)", 0ah, 0
_d

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames dd hnExitProcess - IMAGEBASE, 0
msvcrt.dll_hintnames   dd hnprintf - IMAGEBASE, 0
_d

hnExitProcess _IMAGE_IMPORT_BY_NAME 'ExitProcess'
hnprintf      _IMAGE_IMPORT_BY_NAME 'printf'
_d

kernel32.dll_iat:
__imp__ExitProcess dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll...', 0 ; <===
msvcrt.dll db 'msvcrt.dll.', 0
_d

align FILEALIGN, db 0
