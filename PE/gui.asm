; GUI PE

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
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_GUI ; <==
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint:
    push MB_OK | MB_ICONASTERISK | MB_APPLMODAL
    push aCaption
    push aMsg
    push 0
    call [__imp__MessageBoxA]
_
    push 0
    call [__imp__ExitProcess]
_c

aMsg db " a GUI PE", 0
aCaption db "Corkami", 0

_d

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor user32.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames dd hnExitProcess - IMAGEBASE, 0
user32.dll_hintnames   dd hnMessageBoxA - IMAGEBASE, 0
_d

hnExitProcess _IMAGE_IMPORT_BY_NAME 'ExitProcess'
hnMessageBoxA _IMAGE_IMPORT_BY_NAME 'MessageBoxA'
_d

kernel32.dll_iat:
__imp__ExitProcess dd hnExitProcess - IMAGEBASE
    dd 0

user32.dll_iat:
__imp__MessageBoxA dd hnMessageBoxA - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
user32.dll db 'user32.dll', 0
_d

align FILEALIGN, db 0
