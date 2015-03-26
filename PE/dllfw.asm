; forwarding DLL with minimal export table, and relocations

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers_dll.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,   dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ExportsSize, dd EXPORTS_SIZE    ; exports size is *REQUIRED* in this case
iend

%include 'section_1fa.inc'

EntryPoint:
    push 1
    pop eax
    retn 3 * 4
_c

Exports_Directory: ;************************************************************
istruc IMAGE_EXPORT_DIRECTORY
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd NUMBER_OF_FUNCTIONS
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd NUMBER_OF_NAMES
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_name_ordinals - IMAGEBASE
iend
_d

address_of_functions:
    dd amsvcrt_printf - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd a__exp__Export - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4
_d

amsvcrt_printf db "msvcrt.printf", 0 ; forwarding string can only be within the official export directory bounds
_d

address_of_name_ordinals:
    dw 0
_d

a__exp__Export db 'ExitProcess', 0
_d

EXPORTS_SIZE equ $ - Exports_Directory

align FILEALIGN, db 0
