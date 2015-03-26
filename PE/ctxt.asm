; originally documented by Skywing (http://www.nynaeve.net/?p=127) and enhanced by j00ru (http://j00ru.vexillium.org/?p=80)

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers_dll.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA, dd Exports_Directory - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    cmp dword [esp + 8], DLL_PROCESS_ATTACH ; fdwReason
    jnz skip

    mov eax, dword [esp + 0Ch] ; lpvReserved
	
    add eax, CONTEXT.regEip - 8
    add dword [eax], 20000h
	
    mov eax, 1
skip:
    retn 3 * 4
_c

Exports_Directory: ;************************************************************
istruc IMAGE_EXPORT_DIRECTORY
  at IMAGE_EXPORT_DIRECTORY.nName,                 dd aDllName - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd NUMBER_OF_FUNCTIONS
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd NUMBER_OF_NAMES
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_name_ordinals - IMAGEBASE
iend
_d

aDllName db 'dll.dll', 0
_d


address_of_functions:
    dd -1
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
db ''
    db 0
_d

EXPORT_SIZE equ $ - Exports_Directory

align FILEALIGN, db 0
