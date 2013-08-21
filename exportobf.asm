; PE with fake exports to disrupt disassembly

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA, dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd import_descriptor - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
Export1 equ $ + 1
    push export
Export2 equ $ + 1
    call [__imp__printf]
Export3 equ $ + 1
    add esp, 1 * 4
    retn
_c

export db " * fake exports to disrupt disassembly", 0ah, 0
_d

;*******************************************************************************

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

import_descriptor:
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

hnprintf:
    dw 0
    db 'printf', 0

msvcrt.dll db 'msvcrt.dll', 0

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
    dd Export2 - IMAGEBASE
    dd Export3 - IMAGEBASE
_d

address_of_names:
 times 1 dd name - IMAGEBASE
name db 0

address_of_ordinals dw 0,1,2,3,4,5,6,7

align FILEALIGN, db 0
