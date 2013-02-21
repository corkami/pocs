; complete PE example, as if compiled via MASM, including RichHeader, dos stubs, alignments...

; Ange Albertini, BSD Licence, 2010-2011

IMAGE_SCN_CNT_CODE               equ 000000020h
IMAGE_SCN_CNT_INITIALIZED_DATA   equ 000000040h

%include 'consts.inc'
%define iround(n, r) (((n + (r - 1)) / r) * r)

IMAGEBASE equ 4000000h
org IMAGEBASE

SECTIONALIGN EQU 1000h
FILEALIGN EQU 200h

DOS_HEADER:
    .e_magic       dw 'MZ'
    .e_cblp        dw 090h
    .e_cp          dw 3
    .e_crlc        dw 0
    .e_cparhdr     dw (dos_stub - DOS_HEADER) >> 4 ; defines MZ stub entry point
    .e_minalloc    dw 0
    .e_maxalloc    dw 0ffffh
    .e_ss          dw 0
    .e_sp          dw 0b8h
    .e_csum        dw 0
    .e_ip          dw 0
    .e_cs          dw 0
    .e_lfarlc      dw 040h
    .e_ovno        dw 0
    .e_res         dw 0,0,0,0
    .e_oemid       dw 0
    .e_oeminfo     dw 0
    .e_res2        times 10 dw 0
        align 03ch, db 0    ; in case we change things in DOS_HEADER
    .e_lfanew      dd NT_SIGNATURE - IMAGEBASE ; CRITICAL

align 010h, db 0
dos_stub:
bits 16
    push    cs
    pop     ds
    mov     dx, dos_msg - dos_stub
    mov     ah, 9
    int     21h
    mov     ax, 4c01h
    int     21h
dos_msg
    db 'This program cannot be run in DOS mode.', 0dh, 0dh, 0ah, '$'
;    db 'Win32 EXE!',7,0dh,0ah,'$'

align 16, db 0
RichHeader:
RichKey EQU 092033d19h
dd "DanS" ^ RichKey     , 0 ^ RichKey, 0 ^ RichKey       , 0 ^ RichKey
dd 0131f8eh ^ RichKey   , 7 ^ RichKey, 01220fch ^ RichKey, 1 ^ RichKey
dd "Rich", 0 ^ RichKey  , 0, 0
align 16, db 0

NT_SIGNATURE:
    db 'PE',0,0

FILE_HEADER:
    .Machine                dw IMAGE_FILE_MACHINE_I386
    .NumberOfSections       dw NUMBEROFSECTIONS
    .TimeDateStamp          dd 04b51f504h       ; 2010/1/16 5:19pm
    .PointerToSymbolTable   dd 0
    .NumberOfSymbols        dd 0
    .SizeOfOptionalHeader   dw SIZEOFOPTIONALHEADER
    .Characteristics        dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE| IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE

OPTIONAL_HEADER:
    .Magic                          dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    .MajorLinkerVersion             db 05h
    .MinorLinkerVersion             db 0ch
    .SizeOfCode                     dd SIZEOFCODE
    .SizeOfInitializedData          dd SIZEOFINITIALIZEDDATA
    .SizeOfUninitializedData        dd SIZEOFUNINITIALIZEDDATA
    .AddressOfEntryPoint            dd EntryPoint - IMAGEBASE
    .BaseOfCode                     dd base_of_code - IMAGEBASE
    .BaseOfData                     dd base_of_data - IMAGEBASE
    .ImageBase                      dd IMAGEBASE
    .SectionAlignment               dd SECTIONALIGN
    .FileAlignment                  dd FILEALIGN
    .MajorOperatingSystemVersion    dw 04h
    .MinorOperatingSystemVersion    dw 0
    .MajorImageVersion              dw 0
    .MinorImageVersion              dw 0
    .MajorSubsystemVersion          dw 4
    .MinorSubsystemVersion          dw 0
    .Win32VersionValue              dd 0
    .SizeOfImage                    dd SIZEOFIMAGE
    .SizeOfHeaders                  dd SIZEOFHEADERS
    .CheckSum                       dd 0
    .Subsystem                      dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    .DllCharacteristics             dw 0
    .SizeOfStackReserve             dd 100000H
    .SizeOfStackCommit              dd 1000H
    .SizeOfHeapReserve              dd 100000H
    .SizeOfHeapCommit               dd 1000H
    .LoaderFlags                    dd 0
    .NumberOfRvaAndSizes            dd NUMBEROFRVAANDSIZES

DATA_DIRECTORY:
    .DIRECTORY_ENTRY_EXPORT         dd 0,0
    .DIRECTORY_ENTRY_IMPORT         dd Import_Descriptor - IMAGEBASE, DIRECTORY_ENTRY_IMPORT_SIZE
    .DIRECTORY_ENTRY_RESOURCE       dd 0,0
    .DIRECTORY_ENTRY_EXCEPTION      dd 0,0
    .DIRECTORY_ENTRY_SECURITY       dd 0,0
    .DIRECTORY_ENTRY_BASERELOC      dd 0,0
    .DIRECTORY_ENTRY_DEBUG          dd 0,0
    .DIRECTORY_ENTRY_COPYRIGHT      dd 0,0
    .DIRECTORY_ENTRY_GLOBALPTR      dd 0,0
    .DIRECTORY_ENTRY_TLS            dd 0,0
    .DIRECTORY_ENTRY_LOAD_CONFIG    dd 0,0
    .DIRECTORY_ENTRY_BOUND_IMPORT   dd 0,0
    .DIRECTORY_ENTRY_IAT            dd ImportAddressTable - IMAGEBASE, IAT_size
    .DIRECTORY_ENTRY_DELAY_IMPORT   dd 0,0
    .DIRECTORY_ENTRY_COM_DESCRIPTOR dd 0,0
    .DIRECTORY_ENTRY_RESERVED       dd 0,0
NUMBEROFRVAANDSIZES EQU ($ - DATA_DIRECTORY) / 8
SIZEOFOPTIONALHEADER EQU $ - OPTIONAL_HEADER

; DIRECTORY_ENTRY_DEBUG Size should be small, like 0x1000 or less
; Independantly of NumberOfRvaAndSizes. thus, Dword at DATA_DIRECTORY + 34h

SECTION_HEADER:
SECTION_0:
    .Name                   db '.text'
        times 8 - ($ - .Name) db (0)
    .VirtualSize            dd SECTION0VS; iround(SECTION0SIZE, SECTIONALIGN)
    .VirtualAddress         dd Section0Start - IMAGEBASE
    .SizeOfRawData          dd SECTION0SIZE
    .PointerToRawData       dd SECTION0OFFSET
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_CODE | IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ


SECTION_1:
    .Name                   db '.rdata'
        times 8 - ($ - .Name) db (0)
    .VirtualSize            dd SECTION1VS ; iround(SECTION1SIZE, SECTIONALIGN)
    .VirtualAddress         dd Section1Start - IMAGEBASE
    .SizeOfRawData          dd SECTION1SIZE
    .PointerToRawData       dd SECTION1OFFSET
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ

SECTION_2:
    .Name                   db '.data'
        times 8 - ($ - .Name) db (0)
    .VirtualSize            dd SECTION2VS ; iround(SECTION2SIZE, SECTIONALIGN)
    .VirtualAddress         dd Section2Start - IMAGEBASE
    .SizeOfRawData          dd SECTION2SIZE
    .PointerToRawData       dd SECTION2OFFSET
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE

NUMBEROFSECTIONS EQU ($ - SECTION_HEADER) / 0x28


ALIGN FILEALIGN, db 0
SIZEOFHEADERS EQU $ - IMAGEBASE

SECTION0OFFSET EQU $ - IMAGEBASE

SECTION code valign = SECTIONALIGN
Section0Start:

bits 32
base_of_code:

EntryPoint:
    push Msg
    call printf
    add esp, 1 * 4
    push 0
    call ExitProcess
printf:
    jmp [__imp__printf]
ExitProcess:
    jmp [__imp__ExitProcess]

SECTION0VS equ $ - Section0Start
align FILEALIGN,db 0
SECTION0SIZE EQU $ - Section0Start
SIZEOFCODE equ $ - base_of_code

SECTION1OFFSET equ $ - Section0Start + SECTION0OFFSET
SECTION idata valign = SECTIONALIGN
Section1Start:
base_of_data:

Import_Descriptor:
;kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

ImportAddressTable:
kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d
IAT_size equ $ - ImportAddressTable

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

DIRECTORY_ENTRY_IMPORT_SIZE equ $ - Import_Descriptor
SECTION1VS equ $ - Section1Start

align FILEALIGN,db 0

SECTION1SIZE EQU $ - Section1Start
SECTION2OFFSET equ $ - Section1Start + SECTION1OFFSET
SECTION data valign = SECTIONALIGN

Section2Start:
Msg db " * a 'compiled' PE", 0ah, 0

SECTION2VS equ $ - Section2Start

ALIGN FILEALIGN,db 0
SECTION2SIZE EQU $ - Section2Start
;SIZEOFINITIALIZEDDATA equ $ - base_of_data ; too complex
SIZEOFINITIALIZEDDATA equ SECTION2SIZE + SECTION1SIZE
uninit_data:
SIZEOFUNINITIALIZEDDATA equ $ - uninit_data

SIZEOFIMAGE EQU $ - IMAGEBASE

