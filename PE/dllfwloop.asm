; forwarding DLL with forwarding loop

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
    dd adllfwloop_loophere  - IMAGEBASE
    dd adllfwloop_looponceagain  - IMAGEBASE
    dd amsvcrt_printf - IMAGEBASE
    dd adllfwloop_GroundHogDay - IMAGEBASE
    dd adllfwloop_Yang - IMAGEBASE
    dd adllfwloop_Ying - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd a__exp__ExitProcess - IMAGEBASE
    dd a__exp__LoopHere - IMAGEBASE
    dd a__exp__LoopOnceAgain - IMAGEBASE
    dd a__exp__GroundHogDay - IMAGEBASE
    dd a__exp__Ying - IMAGEBASE
    dd a__exp__Yang - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4
_d

adllfwloop_loophere db 'dllfwloop.LoopHere', 0
adllfwloop_looponceagain db 'dllfwloop.LoopOnceAgain', 0
amsvcrt_printf db "msvcrt.printf", 0
adllfwloop_GroundHogDay db 'dllfwloop.GroundHogDay', 0
adllfwloop_Ying db 'dllfwloop.Ying', 0
adllfwloop_Yang db 'dllfwloop.Yang', 0
_d

address_of_name_ordinals:
    dw 0, 1, 2, 3, 4, 5
_d

a__exp__ExitProcess db 'ExitProcess', 0
a__exp__LoopHere db 'LoopHere', 0
a__exp__LoopOnceAgain db 'LoopOnceAgain', 0
a__exp__GroundHogDay db 'GroundHogDay', 0
a__exp__Ying db 'Ying', 0
a__exp__Yang db 'Yang', 0

_d

EXPORTS_SIZE equ $ - Exports_Directory

align FILEALIGN, db 0
