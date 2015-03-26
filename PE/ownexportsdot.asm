; a PE importing its own exports, but with a trailing dot in the name

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA, dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd import_descriptor - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    jmp [__imp__export]
_c
Export1:
    push export
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

export db " * imports resolving to its own exports", 0ah, 0
_d

msvcrt.dll_iat: ;***************************************************************
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
ownexports.exe_iat:
__imp__export:
    dd hnexport - IMAGEBASE
    dd 0
_d

import_descriptor:
_import_descriptor msvcrt.dll
_import_descriptor ownexports.exe
istruc IMAGE_IMPORT_DESCRIPTOR
iend

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

ownexports.exe_hintnames:
    dd hnexport - IMAGEBASE
    dd 0

hnprintf:
    dw 0
    db 'printf', 0
hnexport:
    dw 0
    db 'export', 0

msvcrt.dll db 'msvcrt.dll', 0
ownexports.exe db 'ownexportsdot.exe.  ... ', 0


Exports_Directory: ;************************************************************
istruc IMAGE_EXPORT_DIRECTORY
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd 3
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd 1
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_ordinals - IMAGEBASE
iend
_d

address_of_functions:
    dd Export1 - IMAGEBASE
_d

address_of_names:
 dd hnexport + 2 - IMAGEBASE

address_of_ordinals dw 0

align FILEALIGN, db 0
