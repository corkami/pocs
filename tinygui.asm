; a universal TinyPE using MessageBox and ExitProcess with contiguous code

; Ange Albertini, BSD Licence, 2010-2013

%include 'consts.inc'

IMAGEBASE equ 400000h

org IMAGEBASE
bits 32

.e_magic dw 'MZ', 0

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,         dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.TimeDateStamp
user32.dll db 'user32.dll', 0
    at IMAGE_FILE_HEADER.Characteristics, dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

istruc IMAGE_OPTIONAL_HEADER32
        at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
        at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
        at IMAGE_OPTIONAL_HEADER32.BaseOfCode,            dd 0 ; must be valid for W7

        at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
        at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd 4
        at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd 4
aTada db "Tada !", 0

        at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
        at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd SIZEOFIMAGE
        at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFIMAGE - 1
        at IMAGE_OPTIONAL_HEADER32.Subsystem,             db IMAGE_SUBSYSTEM_WINDOWS_GUI

        at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 13
iend

istruc IMAGE_DATA_DIRECTORY_CUSTOM
        at IMAGE_DATA_DIRECTORY_CUSTOM.ImportsVA,      dd Import_Descriptor - IMAGEBASE

        at IMAGE_DATA_DIRECTORY_CUSTOM.ResourceVA,     dd 0

        kernel32.dll db 'kernel32.dll' , 0
hnMessageBoxA:
    dw 0
    db 'MessageBoxA'; ,0

        at IMAGE_DATA_DIRECTORY_CUSTOM.DebugSize,      dd 0 ; required for safety under XP

aHelloWorld db "Tiny PE (gui)", 0

        at IMAGE_DATA_DIRECTORY_CUSTOM.TLSVA,          dd 0 ; required for safety under XP
        at IMAGE_DATA_DIRECTORY_CUSTOM.BoundImportsVA, dd 0
        at IMAGE_DATA_DIRECTORY_CUSTOM.IATVA,          dd ImportsAddressTable - IMAGEBASE ; required under XP
        at IMAGE_DATA_DIRECTORY_CUSTOM.IATSize,        dd IMPORTSADDRESSTABLESIZE    ; required under XP
iend

EntryPoint:
    push MB_OK | MB_ICONASTERISK | MB_APPLMODAL
    push aTada
    push aHelloWorld
    push 0
    call [__imp__MessageBoxA]
ImportsAddressTable equ $
Import_Descriptor:
;user32.dll_DESCRIPTOR:
    retn
        times 3 nop
    user32.dll_iat:
    __imp__MessageBoxA:
        dd hnMessageBoxA - IMAGEBASE
        dd 0
    dd user32.dll - IMAGEBASE
    dd user32.dll_iat - IMAGEBASE
IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable
; terminator is in outer space (more like Aliens then ;) )

SIZEOFIMAGE equ $ - IMAGEBASE

struc IMAGE_DATA_DIRECTORY_CUSTOM
    .ExportsVA        resd 1
    .ExportsSize      resd 1
    .ImportsVA        resd 1
    .ImportsSize      resd 1
    .ResourceVA       resd 1
    .ResourceSize     resd 1
    .Exception        resd 2
    .Security         resd 2
    .FixupsVA         resd 1
    .FixupsSize       resd 1
    .DebugVA          resd 1
    .DebugSize        resd 1
    .Description      resd 2
    .MIPS             resd 2
    .TLSVA            resd 1
    .TLSSize          resd 1
    .Load             resd 2
    .BoundImportsVA   resd 1
    .BoundImportsSize resd 1
    .IATVA            resd 1
    .IATSize          resd 1
endstruc
