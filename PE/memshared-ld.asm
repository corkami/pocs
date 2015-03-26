; MEMSHARED dll loader

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

LIMIT equ 3

EntryPoint:
    push memshared
    call [__imp__LoadLibraryA]

    add eax, SECTIONALIGN ; it's at the start of 1st section
    mov dword [lpValue], eax
_
    mov eax, dword [eax]
    push eax

    sub dword [esp], LIMIT
    neg dword [esp]

    push eax
_
    push Msg
    call [__imp__printf]
    add esp, 3 * 4
_
    mov eax, dword [lpValue]
    inc dword [eax]
    mov ebx, dword [eax]
    cmp ebx, 1 ; first launch?
    jg noloop
_

loop_: ; waiting for other launches
_
;    push eax ; careful with infinite loops and deadlocks:p
;    push 0
;    push 0
;    push 0
;    push memsharedld
;    push 0
;    push 0
;    call [__imp__shellexecute]
;    pop eax
    
    mov ebx, dword [eax]
    cmp ebx, LIMIT + 1
    jnz loop_
_

noloop:
    push 0
    call [__imp__ExitProcess]
_c

lpValue dd 0

memshared db 'memshared.dll', 0
;memsharedld db 'memshared-ld.exe', 0
_d

Msg db ' * current value stored in MEM_SHARED section: %i (launch me %i more times to make me exit)', 0dh, 0ah, 0
_d

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
;_import_descriptor shell32.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnLoadLibraryA - IMAGEBASE
    dd 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__LoadLibraryA:
    dd hnLoadLibraryA - IMAGEBASE
    dd 0
_d

hnExitProcess    _IMAGE_IMPORT_BY_NAME 'ExitProcess'
hnLoadLibraryA   _IMAGE_IMPORT_BY_NAME 'LoadLibraryA'
_d

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnprintf _IMAGE_IMPORT_BY_NAME 'printf'
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

;shell32.dll_hintnames:
;    dd hnshellexecute - IMAGEBASE
;    dd 0
;
;shell32.dll_iat:
;__imp__shellexecute:
;    dd hnshellexecute - IMAGEBASE
;    dd 0
;_d
;
;shell32.dll db 'shell32.dll', 0
;hnshellexecute _IMAGE_IMPORT_BY_NAME 'ShellExecuteA'

align FILEALIGN, db 0

;*******************************************************************************

