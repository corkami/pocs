; a PE with a bogus ControlFlow Guard table (Subsystem version too old)

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 6
    at IMAGE_OPTIONAL_HEADER32.MinorSubsystemVersion, dw 1 ; <= version too old for CFG
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.DllCharacteristics,    dw IMAGE_DLLCHARACTERISTICS_GUARD_CF
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Load,      dd LoadConfig - IMAGEBASE, LOADCONFIGSIZE
iend

%include 'section_1fa.inc'

EntryPoint: ;*******************************************************************
    push Msg
    call [__imp__printf]
    add esp, 2 * 4

error_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * a PE with a bogus ControlFlow Guard table", 0ah, 0
_d

LoadConfig: ;*******************************************************************

istruc IMAGE_LOAD_CONFIG_DIRECTORY32
    at IMAGE_LOAD_CONFIG_DIRECTORY32.Size,                        dd IMAGE_LOAD_CONFIG_DIRECTORY32_size
    at IMAGE_LOAD_CONFIG_DIRECTORY32.SecurityCookie,              dd cookie
    at IMAGE_LOAD_CONFIG_DIRECTORY32.SEHandlerCount
    at IMAGE_LOAD_CONFIG_DIRECTORY32.GuardCFCheckFunctionPointer, dd CheckFunctionPointer
    at IMAGE_LOAD_CONFIG_DIRECTORY32.GuardCFFunctionTable,        dd FunctionTable
    at IMAGE_LOAD_CONFIG_DIRECTORY32.GuardCFFunctionCount,        dd FUNCTIONCOUNT
    at IMAGE_LOAD_CONFIG_DIRECTORY32.GuardFlags,                  dd IMAGE_GUARD_CF_INSTRUMENTED | IMAGE_GUARD_CF_FUNCTION_TABLE_PRESENT
iend

LOADCONFIGSIZE equ $ - LoadConfig

cookie dd COOKIE_DEFAULT, COOKIE_DEFAULT ^ 0ffffffffh

CheckFunctionPointer:
    dd CheckFunction

CheckFunction:
    retn

FunctionTable:
    dd EntryPoint - IMAGEBASE
    dd EntryPoint - 1 - IMAGEBASE
    dd EntryPoint + 1 - IMAGEBASE
    dd EntryPoint + 3 - IMAGEBASE
    dd 07fffffffh
    dd -1
    FUNCTIONCOUNT equ ($ - FunctionTable) / 4
    dd 0


Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames dd hnExitProcess - IMAGEBASE, 0
msvcrt.dll_hintnames   dd hnprintf - IMAGEBASE, 0
_d

hnExitProcess         db 0,0, 'ExitProcess', 0
hnprintf              db 0,0, 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_iat:
__imp__printf dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0
