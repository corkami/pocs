; PE with exports with the same name - and the right one is called via hints

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA, dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    jmp [__imp__export]
_c

FakeExport:
    push afakeexport
    call [__imp__printf]
    add esp, 1 * 4
    retn
FakeExport2:
_c

afakeexport db " * ERROR - incorrect import called (hint ignored ?)", 0ah, 0
_d

;*******************************************************************************
msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
importhints.exe_iat:
__imp__export:
    dd hnexport - IMAGEBASE
    dd 0
_d

Import_Descriptor:
_import_descriptor msvcrt.dll
_import_descriptor importhints.exe
istruc IMAGE_IMPORT_DESCRIPTOR
iend

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

importhints.exe_hintnames:
    dd hnexport - IMAGEBASE
    dd 0

hnprintf:
    dw 0
    db 'printf', 0
_d

msvcrt.dll db 'msvcrt.dll', 0
importhints.exe db 'importshint.exe', 0
_d

Exports_Directory: ;************************************************************
istruc IMAGE_EXPORT_DIRECTORY
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd 4
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd 4
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_ordinals - IMAGEBASE
iend
_d

address_of_functions:
    dd FakeExport - IMAGEBASE
    dd FakeExport2 - IMAGEBASE
    dd GoodExport - IMAGEBASE
    dd FakeExport - IMAGEBASE
_d

address_of_names:
 dd hnexport + 2 - IMAGEBASE
 dd someothername - IMAGEBASE
 dd hnexport + 2 - IMAGEBASE
 dd hnexport + 2 - IMAGEBASE


someothername db 'export:    CC   oops I did it again...      ', 0
_d
address_of_ordinals dw 0, 1, 2, 3

hnexport:
    dw 2 ; <== here is the hint that gives the loader the starting position in the address_of_functions array
    db 'export', 0
_d

GoodExport:
    push agoodexport
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

agoodexport db " * correct import called via hinting", 0ah, 0
_d

align FILEALIGN, db 0
