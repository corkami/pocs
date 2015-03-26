; d_nonnull.dll static loader

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'
%include 'section_1fa.inc'

EntryPoint:
	push LOAD_LIBRARY_AS_DATAFILE
	push 0
    push dll.dll
    call [__imp__LoadLibraryExA] ; <=====
_
	and eax, 0ffff0000h
	add eax, 40h
	jmp eax
_c

dll.dll db 'd_nonnull.dll', 0
_d

Import_Descriptor:
_import_descriptor kernel32.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnLoadLibraryExA - IMAGEBASE
    dd 0
_d


hnLoadLibraryExA:
    dw 0
    db 'LoadLibraryExA', 0
_d

kernel32.dll_iat:
__imp__LoadLibraryExA:
    dd hnLoadLibraryExA - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
_d

align FILEALIGN, db 0

