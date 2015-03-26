; tiny.dll static loader

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
	push LOAD_LIBRARY_AS_DATAFILE
	push 0
	push dll.dll
	call [__imp__LoadLibraryExA]
_
	and eax, 0ffff0000h
	add eax, 6
	push eax
    call [__imp__printf]
_
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess]
_c

dll.dll db 'd_tiny.dll', 0
_d

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnLoadLibraryExA - IMAGEBASE
    dd 0
_d

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
_d

hnLoadLibraryExA:
    dw 0
    db 'LoadLibraryExA', 0
_d

hnprintf:
    dw 0
    db 'printf', 0

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__LoadLibraryExA:
    dd hnLoadLibraryExA - IMAGEBASE
    dd 0
_d

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0
