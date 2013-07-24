; a 'broken' PE that fixes that itself via its dos stub

; Ange Albertini, BSD Licence, 2012

IMAGE_SCN_CNT_CODE               equ 000000020h
IMAGE_SCN_CNT_INITIALIZED_DATA   equ 000000040h

%include 'consts.inc'
%define iround(n, r) (((n + (r - 1)) / r) * r)

IMAGEBASE equ 4000000h
org IMAGEBASE

SECTIONALIGN EQU 1000h
FILEALIGN EQU 200h

DOS_HEADER:
istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,    db 'MZ'
    at IMAGE_DOS_HEADER.e_cblp,     dw 090h
    at IMAGE_DOS_HEADER.e_cp,       dw 5
    at IMAGE_DOS_HEADER.e_cparhdr,  dw (dos_stub - IMAGEBASE) >> 4
    at IMAGE_DOS_HEADER.e_maxalloc, dw 0ffffh
    at IMAGE_DOS_HEADER.e_sp,       dw stub_end + 20h - dos_stub
    at IMAGE_DOS_HEADER.e_lfarlc,   dw 040h
    at IMAGE_DOS_HEADER.e_lfanew,   dd NT_SIGNATURE - IMAGEBASE
iend

align 010h, db 0
dos_stub:
FILESIZE equ 2560
bits 16
; init ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    cs
    pop     ds
;   sp is already set via the DOS header
    mov     dx, dos_msg - dos_stub
    mov     ah, 9 ; print
    int     21h

; shrink image before allocating ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     ah, 4ah ; reallocate
    mov     sp, stub_end - dos_stub
    mov     bx, sp ;effective end of image
    add     bx, 20fh ;it's relative to ds, not cs, round up to next paragraph
    shr     bx, 4 ;convert to paragraphs
    int     21h
_
; allocate buffer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     ah, 48h ; allocate
    mov     bx, (FILESIZE + 0fh) >> 4
    int     21h
    jc      end_
    mov     [hbuf - dos_stub], ax
_
    ; open itself for reading
    mov     ah, 3dh ; opening
    mov     al, 0
    mov     dx, thisfile - dos_stub
    int     21h
    jc      end_
    mov     [hthis - dos_stub], ax

; create target;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     ah, 03ch ; create file
    mov     cx, 0 ; normal attributes
    mov     dx, new - dos_stub
    int     21h
    jc      end_
    mov     [hnew - dos_stub], ax
_
; read buffer;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    ds
    mov     ah, 3fh ; reading
    mov     bx, [hthis - dos_stub]
    mov     ds, [hbuf - dos_stub]
    mov     dx, 0
    mov     cx, FILESIZE
    int     21h
    pop     ds
    jc      end_

; fix the PE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    es
    mov     di, NT_SIGNATURE - IMAGEBASE
    mov     es, [hbuf - dos_stub]
    mov     al, 'P'
    stosb
    pop     es
_
    mov     bx, [hnew - dos_stub]
    push    ds
    mov     ah, 40h ; writing
    mov     ds, [hbuf - dos_stub]
    mov     dx, 0
    mov     cx, FILESIZE
    int     21h
    pop     ds
    jc      end_

; close target file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     ah, 3eh ; close file
    mov     bx, [hnew - dos_stub]
    int     21h
    jc end_

    mov     ah, 3eh ; close file
    mov     bx, [hthis - dos_stub]
    int     21h
    jc      end_

; executing PE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    ds
    pop     es
    mov     bx, block - dos_stub
    mov     word [bx + 4], ds
    mov     word [bx + 8], ds
    mov     word [bx + 0ch], ds
    mov     ah, 4bh ; execute
    mov     al, 0 ; load & execute
    mov     dx, new - dos_stub ; file name
    ; mov cx, 0 ; children mode
    int     21h
    jc      end_
_
end_:
    mov     ax, 4c01h
    int     21h

hthis dw 0
hnew dw 0
hbuf dw 0

thisfile db 'exe2pe.exe', 0
new db 'ep.exe', 0
dos_msg db ' # patching PE (16b dos stub)', 0dh, 0dh, 0ah, '$'
block:
    dw 0, 80h ; command tail
    dw 0, 5ch ; first fcb
    dw 0, 6ch ; second fcb
    dw 0 ; used when AL = 1
align 16, db 0
stub_end:

RichHeader:
dd "DanS" ^ RichKey     , 0 ^ RichKey, 0 ^ RichKey       , 0 ^ RichKey
dd 0131f8eh ^ RichKey   , 7 ^ RichKey, 01220fch ^ RichKey, 1 ^ RichKey
dd "Rich", 0 ^ RichKey  , 0, 0
align 16, db 0

NT_SIGNATURE:
    db 'NE',0,0

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
Msg db " # PE executed (32b PE)", 0ah, 0

SECTION2VS equ $ - Section2Start

ALIGN FILEALIGN,db 0
SECTION2SIZE EQU $ - Section2Start
;SIZEOFINITIALIZEDDATA equ $ - base_of_data ; too complex
SIZEOFINITIALIZEDDATA equ SECTION2SIZE + SECTION1SIZE
uninit_data:
SIZEOFUNINITIALIZEDDATA equ $ - uninit_data

SIZEOFIMAGE EQU $ - IMAGEBASE
