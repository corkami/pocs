; a 268-bytes tiny DLL

;Ange Albertini, BSD Licence, 2010-2013

%include 'consts.inc'

IMAGEBASE equ 3300000h
bits 32

org IMAGEBASE

DOS_HEADER:
.e_magic dw 'MZ'

align 4, db 0

istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine, dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.Characteristics, dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL
iend

istruc TRUNC_OPTIONAL_HEADER32
    at TRUNC_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at TRUNC_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE ; would also work with a null EntryPoint
    at TRUNC_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at TRUNC_OPTIONAL_HEADER32.SectionAlignment,      dd 4       ; also sets e_lfanew
    at TRUNC_OPTIONAL_HEADER32.FileAlignment,         dd 4
    at TRUNC_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at TRUNC_OPTIONAL_HEADER32.SizeOfImage,           dd SIZEOFIMAGE
    at TRUNC_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at TRUNC_OPTIONAL_HEADER32.Subsystem,             db IMAGE_SUBSYSTEM_WINDOWS_GUI
iend
    db 0 ; one byte delta to avoid setting DllCharacteristics to AppContainer

SIZEOFHEADERS equ $ - IMAGEBASE

; EntryPoint needs to be out of the header in Windows 8
EntryPoint:
    push 1
    pop eax
    retn 3 * 4

align 16, db 0
db '  * tiny DLL loaded', 0ah, 0
    align 16, db 0

times 268-80h db 0
SIZEOFIMAGE equ $ - IMAGEBASE