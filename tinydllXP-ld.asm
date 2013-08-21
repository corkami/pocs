; tiny dll loader

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
    push dll.dll
    call [__imp__LoadLibraryA]
    test eax, eax
    jz end_
_
    push loading
    call [__imp__printf]
    add esp, 1 * 4
end_:
    push 0
    call [__imp__ExitProcess]
_c

start db ' * dynamically loading minimal 97 bytes DLL', 0ah, 0
loading db '  # dll loaded', 0ah, 0
_d

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnLoadLibraryA - IMAGEBASE
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

hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__LoadLibraryA:
    dd hnLoadLibraryA - IMAGEBASE
    dd 0
_d

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
dll.dll db 'tinydllXP.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0
