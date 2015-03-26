; PE with exports as internal documentation

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,  dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd Import_Descriptor - IMAGEBASE
iend

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * PE with exports as internal documentation", 0ah, 0
_d

;------------------------------------------------------------------------------

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

ImportsAddressTable: ; <=
kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d
IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable
kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

;------------------------------------------------------------------------------

Exports_Directory:
istruc IMAGE_EXPORT_DIRECTORY
  at IMAGE_EXPORT_DIRECTORY.nName,                 dd aDllName - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd NUMBER_OF_FUNCTIONS
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd NUMBER_OF_NAMES
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_name_ordinals - IMAGEBASE
iend
_d

aDllName db 'unused',
_d

address_of_functions:
    dd -1 ; won't work
    dd EntryPoint - IMAGEBASE
    dd Import_Descriptor - IMAGEBASE
    dd Exports_Directory - IMAGEBASE
    dd ImportsAddressTable - IMAGEBASE
    dd 2 * FILEALIGN
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd szDosHeader - IMAGEBASE ;address 0 fails
    dd szEntryPoint - IMAGEBASE
    dd szImport_Descriptor - IMAGEBASE
    dd szExports_Directory - IMAGEBASE
    dd szImportsAddressTable - IMAGEBASE
    dd szEOF - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4

szDosHeader           db "szDosHeader", 0
szEntryPoint          db "EntryPoint",0
szExports_Directory   db "Exports Directory",0
szImport_Descriptor   db "Imports",0
szImportsAddressTable db "Imports Address Table",0
szEOF db "EOF", 0

_d
address_of_name_ordinals:
    dw 0, 1, 2, 3, 4, 5
_d

;------------------------------------------------------------------------------

align FILEALIGN, db 0
