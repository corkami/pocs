; DLL with empty export name

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers_dll.inc'

%include 'dd_dll.inc'

%include 'section_1fa.inc'

EntryPoint:
    push 1
    pop eax
    retn 3 * 4
_c

__exp__Export:
reloc31:
    push export
reloc42:
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

export db " * statically loaded DLL with empty export name", 0ah, 0
_d

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
    DD hnprintf - IMAGEBASE
    DD 0

hnprintf:
    dw 0
    db 'printf', 0

msvcrt.dll db 'msvcrt.dll', 0

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

aDllName db 'completely unrelated dll name', 1, 2, 3, 4, 0
_d


address_of_functions:
    dd __exp__Export - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd a__exp__Export - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4

_d
address_of_name_ordinals:
    dw 0
_d

a__exp__Export:
    db 0
_d

EXPORT_SIZE equ $ - Exports_Directory

Directory_Entry_Basereloc:
block_start0:
    .VirtualAddress dd reloc31 - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc31 + 1 - reloc31)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - reloc31)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0
