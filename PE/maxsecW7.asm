; PE with 8192 used code sections

; Ange Albertini, BSD LICENCE 2009-2013

; YASM has a bug, it can't get its own line number correct after too many repeats and align. 
; so jmp $ will not even be correct, so alignments have to be hardcoded :(

%include 'consts.inc'

IMAGEBASE equ 010000h
SECTIONALIGN equ 1000h ; smallest section alignment 
FILEALIGN equ 200h


EXTRA equ 8191
SECTOFF equ 50200h ; first section's offset
SECTRVA equ 51000h ; first sections RVA (= SECTOFF rounded up to SECTIONALIGN)
VDELTA equ 0E00h; VIRTUAL DELTA between this sections offset and virtual addresses

HEADERALIGN equ 0c8h
FIRSTSECALIGN equ 010eh

IMPORTSRVA equ 51022h


org IMAGEBASE
bits 32

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
    at IMAGE_FILE_HEADER.NumberOfSections,     dw EXTRA + 1 ; <==
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd SECTRVA + EXTRA * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd SECTRVA + SECTIONALIGN * (EXTRA + 1)
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SECTOFF
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd IMPORTSRVA
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd SECTRVA
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd SECTOFF
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend

%assign i 1
%rep    EXTRA
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd SECTRVA + i * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd SECTOFF + i * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
%assign i i+1
%endrep

times HEADERALIGN db 0 ; align FILEALIGN, db 0

; VAs are invalid beyond this point, have to be adjusted manually

EntryPoint:
    push VDELTA + message
    call printf
    add esp, 1 * 4
    push 0
    call ExitProcess
int3

printf:
    jmp [VDELTA + __imp__printf]
ExitProcess:
    jmp [VDELTA + __imp__ExitProcess]
int3

; IMPORT DATA DIRECTORY AND TABLE
Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk , dd VDELTA + kernel32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1              , dd VDELTA + kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk         , dd VDELTA + kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk , dd VDELTA + msvcrt.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1              , dd VDELTA + msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk         , dd VDELTA + msvcrt.dll_iat - IMAGEBASE
iend
;I'll be back
istruc IMAGE_IMPORT_DESCRIPTOR
iend
dd 0

kernel32.dll_hintnames:
    dd VDELTA + hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd VDELTA + hnprintf - IMAGEBASE
    dd 0
dd 0

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
dd 0

kernel32.dll_iat:
__imp__ExitProcess:
    dd VDELTA + hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd VDELTA + hnprintf - IMAGEBASE
    dd 0
dd 0

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
dd 0

;*******************************************************************************
; DATA (after imports, for fewer manual adjustments)

message db     " * PE with 8192 code sections (W7)", 0ah, 0

times 0dh db 0

times FIRSTSECALIGN db 0 ;align FILEALIGN, db 0

; now let's create filespace and code for the extra sections
%assign i 1
%rep    EXTRA
times 126 db 0ebh, 0ffh, 0c0h, 048h
jmp $ + 2
db 67h
jmp $ - 1000h - 2 * 253 - 1
%assign i i+1
%endrep
