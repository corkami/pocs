; a PE to gather kernel32 timestamps + GPA and LoadLibraryA RVAs

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
    mov eax, [esp]
    and eax, 0ffff0000h

scanMZ:
    sub eax, 10000h
    cmp dword [eax], 00905a4dh
    jnz scanMZ

    mov ebx, eax
    mov ecx, eax

    add eax, 3ch
    mov eax, [eax]
    add ebx, eax

    cmp dword [ebx], 00004550h
    jnz end_
    add ebx, 8

    mov edx, dword [__imp__GetProcAddress]
    sub edx, ecx
    push edx

    mov edx, dword [__imp__LoadLibraryA]
    sub edx, ecx
    push edx

    push dword [ebx]

    push Msg
    call [__imp__printf]
    add esp, 4 * 4
_
end_:
    push 0
    call [__imp__ExitProcess]
_c

Msg db "; K32stamp, LLrva, GPArva", 0ah
    db "    dd 0%08xh, 0%05xh, 0%05xh", 0ah, 0
_d

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd kernel32.dll_iat - IMAGEBASE
iend                                     
istruc IMAGE_IMPORT_DESCRIPTOR           
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

hnExitProcess    db 0,0, 'ExitProcess', 0
hnLoadLibraryA   db 0,0, 'LoadLibraryA', 0
hnGetProcAddress db 0,0, 'GetProcAddress', 0
hnprintf         db 0,0, 'printf', 0
_d

kernel32.dll_iat
__imp__ExitProcess    dd hnExitProcess - IMAGEBASE
__imp__GetProcAddress dd hnGetProcAddress - IMAGEBASE
__imp__LoadLibraryA   dd hnLoadLibraryA - IMAGEBASE
                      dd 0

msvcrt.dll_iat
__imp__printf dd hnprintf - IMAGEBASE
              dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0
