; a PE using Win32VersionValue to override OS version numbers

; Ange Albertini, BSD LICENCE 2012-2013

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

OSMAJOR equ 31
OSMINOR equ 41
BUILD equ 5926
ID equ 3 ; [0;3]

	at IMAGE_OPTIONAL_HEADER32.Win32VersionValue,     dd \
        OSMAJOR | (OSMINOR << 8) | ((BUILD & 03fffh) << 16) | (((ID & 3) ^ 02h) << 30)

    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

%include 'dd_imports.inc'

%include 'section_1fa.inc'

EntryPoint: ;*******************************************************************
    push OSVerEx
    call [__imp__GetVersionExA]

    push dword [OSVerEx.dwPlatformId]
    push dword [OSVerEx.dwBuildNumber]

    push dword [OSVerEx.dwMinorVersion]
    push dword [OSVerEx.dwMajorVersion]

    push Msg
    call [__imp__printf]
    add esp, 4 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * a PE overriding OS values: OS Ver %i.%i.%i PlatformID %i", 0ah, 0ah, 0
_d

OSVerEx: ;**********************************************************************
  .dwOSVersionInfoSize dd OSVerExSize
  .dwMajorVersion dd 0
  .dwMinorVersion dd 0
  .dwBuildNumber dd 0
  .dwPlatformId dd 0
  .szCSDVersion times 128 db 0
  .wServicePackMajor dw 0
  .wServicePackMinor dw 0
  .wSuiteMask dw 0
  .wProductType db 0
  .wReserved db 0
OSVerExSize equ $ - OSVerEx
_d

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
	dd hnGetVersionExA - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnGetVersionExA:
	dw 0
	db 'GetVersionExA', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__GetVersionExA:
	dd hnGetVersionExA - IMAGEBASE
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
