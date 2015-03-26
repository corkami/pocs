; dll loader

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'
%include 'dd_imports.inc'
%include 'section_1fa.inc'

EntryPoint:
    push start
    call [__imp__printf]
    add esp, 1 * 4
_
    push loading
    call [__imp__printf]
    add esp, 1 * 4
_
    push dll.dll
    call [__imp__LoadLibraryA]
    mov [h], eax
_
    push unloading
    call [__imp__printf]
    add esp, 1 * 4
_
    push dword [h]
    call [__imp__FreeLibrary]
_
    push 0
    call [__imp__ExitProcess]
_c

start db ' * dynamically loading export-less DLL', 0ah, 0
loading db '  # loading dll', 0ah, 0
unloading db '  # unloading dll', 0ah, 0
_d

h dd 0

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnLoadLibraryA - IMAGEBASE
    dd hnFreeLibrary - IMAGEBASE
    dd hnGetProcAddress - IMAGEBASE
    dd 0
_d

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
_d

hnLoadLibraryA:
    dw 0
    db 'LoadLibraryA', 0
_d

hnFreeLibrary:
    dw 0
    db 'FreeLibrary', 0
_d

hnGetProcAddress:
    dw 0
    db 'GetProcAddress', 0
_d

export db 'export', 0
_d

hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__LoadLibraryA:
    dd hnLoadLibraryA - IMAGEBASE
__imp__FreeLibrary:
    dd hnFreeLibrary - IMAGEBASE
__imp__GetProcAddress:
    dd hnGetProcAddress - IMAGEBASE
    dd 0
_d

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
dll.dll db 'dllnoexp.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0

