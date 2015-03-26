; DLL with a negative entrypoint - that is *NOT* called

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

EntryPoint equ 1401001h

%include 'headers_dll.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA, dd Exports_Directory - IMAGEBASE
iend

%include 'section_1fa.inc'

db ' * negative entrypoint for DllMain in the EXE', 0
__exp__Export:
	hlt

EP:
	xor eax, eax
	inc eax
	retn 0ch

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
db 'export'
    db 0
_d

EXPORT_SIZE equ $ - Exports_Directory

align FILEALIGN, db 0
