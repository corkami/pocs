; PE with 96 code sections, fully used

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'
%define iround(n, r) (((n + (r - 1)) / r) * r)

EXTRA equ 95
VEXTRA equ 1000h ;+ 1000h to compensate with sizeofheaders

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
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd VDELTA + EntryPoint - IMAGEBASE + EXTRA * SECTIONALIGN ;<====
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd VDELTA + SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd VDELTA + Import_Descriptor - IMAGEBASE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd Section0Size
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd VDELTA + Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd iround(Section0Size, FILEALIGN)
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE
iend

%assign i 1
%rep    EXTRA
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd Section0Size
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd VDELTA + Section0Start - IMAGEBASE + i * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE + FILEALIGN * i
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE
iend
%assign i i+1
%endrep

NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

ALIGN FILEALIGN, db 0

SIZEOFHEADERS equ $ - IMAGEBASE

Section0Start:
VDELTA equ VEXTRA + SECTIONALIGN - ($ - IMAGEBASE) ; VIRTUAL DELTA between this sections offset and virtual addresses

EntryPoint:
;    push VDELTA + end_
;    push dword [fs:0]
;    mov [fs:0], esp
;    mov eax, ebx
;    jmp zeroes_
;end_:
    push VDELTA + message
    call printf
    add esp, 1 * 4
    push 0
    call ExitProcess
_c
printf:
    jmp [VDELTA + __imp__printf]
ExitProcess:
    jmp [VDELTA + __imp__ExitProcess]
_c

message db " * a PE with 96 used code sections", 0ah, 0
_d

Import_Descriptor: ;************************************************************
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd VDELTA + kernel32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1             , dd VDELTA + kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd VDELTA + kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd VDELTA + msvcrt.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1             , dd VDELTA + msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd VDELTA + msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd VDELTA + hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd VDELTA + hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd VDELTA + hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd VDELTA + hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

;*******************************************************************************
zeroes_:
align FILEALIGN, db 0

Section0Size EQU $ - Section0Start

%assign i 1
%rep    EXTRA
; style 1: only zeroes, use with SEH on final procedure => uses all 00s, including virtual ones
; times 200h db 0

; style 2: inc eax/dec eax with jmp backwards
;times 84 db 0ebh, 0ffh, 0c0h, 0ebh, 0ffh, 0c8h

;style 3: inc eax backward then dec eax forward => nice looping effect
times 126 db 0ebh, 0ffh, 0c0h, 048h
jmp $ + 2
db 67h
jmp $ - 1000h - 2 * 253 - 1
%assign i i+1
%endrep

SIZEOFIMAGE EQU $ - IMAGEBASE + SECTIONALIGN * EXTRA - 0b000h ;?
