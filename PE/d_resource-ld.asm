; loader for resource-only data PE

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

SOME_TYPE equ 315h
SOME_NAME equ 7354h

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
	push LOAD_LIBRARY_AS_DATAFILE
	push 0
    push dll.dll
    call [__imp__LoadLibraryExA]
	mov [hLib], eax
_
    push SOME_TYPE              ; lpType
    push SOME_NAME              ; lpName
    push dword [hLib]           ; hModule
    call [__imp__FindResourceA]
	mov [hRes], eax
_
    push dword [hRes]
    push dword [hLib]           ; hModule
    call [__imp__LoadResource]
_
    push eax
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

hLib dd 0
hRes dd 0
dll.dll db 'd_resource.dll', 0
_d

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnFindResourceA - IMAGEBASE
    dd hnLoadResource - IMAGEBASE
    dd hnLoadLibraryExA - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnFindResourceA:
    dw 0
    db 'FindResourceA', 0
hnLoadResource:
    dw 0
    db 'LoadResource', 0
hnLoadLibraryExA:
    dw 0
    db 'LoadLibraryExA', 0

hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__FindResourceA:
    dd hnFindResourceA - IMAGEBASE
__imp__LoadResource:
    dd hnLoadResource  - IMAGEBASE
__imp__LoadLibraryExA:
    dd hnLoadLibraryExA - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d


align FILEALIGN, db 0
