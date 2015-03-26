; a DYNAMIC_BASE DLL loader

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'
%include 'dd_imports.inc'
%include 'section_1fa.inc'

EntryPoint:
    inc dword [counter]
    cmp dword [counter], 9
    jz end_

    push aslr.dll
    call [__imp__LoadLibraryA]
    mov [h], eax

    push eax
    push msg
    call [__imp__printf]
    add esp, 2 * 4
_
    push dword [h]
    call [__imp__FreeLibrary]
    jmp EntryPoint
_
end_:
    push 0
    call [__imp__ExitProcess]
_c

msg db ' * DYNAMIC_BASE DLL loaded (ImageBase 0%08xh)', 0ah, 0
_d

h dd 0
exp dd 0
counter dd 0
_d

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

hnExitProcess    _IMAGE_IMPORT_BY_NAME 'ExitProcess'
hnprintf         _IMAGE_IMPORT_BY_NAME 'printf'
hnLoadLibraryA   _IMAGE_IMPORT_BY_NAME 'LoadLibraryA'
hnFreeLibrary    _IMAGE_IMPORT_BY_NAME 'FreeLibrary'
hnGetProcAddress _IMAGE_IMPORT_BY_NAME 'GetProcAddress'
_d

kernel32.dll_iat:
__imp__ExitProcess    dd hnExitProcess - IMAGEBASE
__imp__LoadLibraryA   dd hnLoadLibraryA - IMAGEBASE
__imp__FreeLibrary    dd hnFreeLibrary - IMAGEBASE
__imp__GetProcAddress dd hnGetProcAddress - IMAGEBASE
    dd 0
_d

msvcrt.dll_iat:
__imp__printf dd hnprintf - IMAGEBASE
    dd 0

msvcrt.dll db 'msvcrt.dll', 0
kernel32.dll db 'kernel32.dll', 0
aslr.dll db 'aslr.dll', 0
_d

align FILEALIGN, db 0

