; a PE enabling LoaderSnaps via its LoadConfig DataDirectory

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Load,      dd LoadConfig - IMAGEBASE, 40h ; fixed XP value?
iend

%include 'section_1fa.inc'

EntryPoint: ;*******************************************************************
    call [__imp__RtlGetNtGlobalFlags]
    push eax
    and eax, 2
    jz error_
_
    push Msg
    call [__imp__printf]
    add esp, 2 * 4

error_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * a PE enabling LoaderSnaps via its LoadConfig DataDirectory (GlobalFlags: %08X)", 0ah, 0
_d

LoadConfig: ;*******************************************************************

istruc IMAGE_LOAD_CONFIG_DIRECTORY32
    at IMAGE_LOAD_CONFIG_DIRECTORY32.Size,           dd IMAGE_LOAD_CONFIG_DIRECTORY32_size
    at IMAGE_LOAD_CONFIG_DIRECTORY32.GlobalFlagsSet, dd FLG_SHOW_LDR_SNAPS
iend

LOADCONFIGSIZE equ $ - LoadConfig

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
_import_descriptor ntdll.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames dd hnExitProcess - IMAGEBASE, 0
ntdll.dll_hintnames    dd hnRtlGetNtGlobalFlags - IMAGEBASE, 0
msvcrt.dll_hintnames   dd hnprintf - IMAGEBASE, 0
_d

hnExitProcess         db 0,0, 'ExitProcess', 0
hnRtlGetNtGlobalFlags db 0,0, 'RtlGetNtGlobalFlags', 0
hnprintf              db 0,0, 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_iat:
__imp__printf dd hnprintf - IMAGEBASE
    dd 0
ntdll.dll_iat:
__imp__RtlGetNtGlobalFlags dd hnRtlGetNtGlobalFlags - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
ntdll.dll db 'ntdll.dll', 0
_d

align FILEALIGN, db 0
