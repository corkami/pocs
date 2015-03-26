; combining relocations type to create a loader-based OS detection

; initially published with an article in
;  Proceedings of the Society of PoC||GTFO Issue 0x01
;  http://www.h2hc.com.br/pocorgtfo/pocorgtfo01.pdf

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 0ffff0000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

%include "nthd_std.inc"

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

relocbase: ; we'll apply a bogus relocation type 10 with Windows 8 here

const equ (IMAGE_REL_BASED_MIPS_JMPADDR16 << 12) | 0d00h
; => type/offset:
;    9 f00 under XP/W7
;    a 000 under W8

Directory_Entry_Basereloc: ;****************************************************

; we use 3 blocks:

;standard code relocation
block_start0:
    .VirtualAddress dd relocbase - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 1 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc12 + 2 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc21 + 1 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc31 + 1 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc52 + 2 - relocbase)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

;relocation type 4, helping to disable the unsupported relocation type 9 under Windows 8
block_start1:
    .VirtualAddress dd relocbase - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK1
    dw (IMAGE_REL_BASED_HIGHADJ  << 12) | (reloc4 + 1 - relocbase), -1 ; +1 to modify the Type
BASE_RELOC_SIZE_OF_BLOCK1 equ $ - block_start1

; our type9/type10 relocation: type 10 under Windows8, then type 9 under XP/W7, where it behaves differently
block_start2:
    .VirtualAddress dd relocbase - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK2
reloc4
    dw const
BASE_RELOC_SIZE_OF_BLOCK2 equ $ - block_start2

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc
    dw 0

_d

%include 'imports_printfexitprocess.inc'

EntryPoint: ;*******************************************************************
reloc01:
    push msg
reloc12:
    call [__imp__printf]
    add esp, 1 * 4
    
reloc21:
    mov eax, dword [relocbase + 0f00h + 0ch]

    cmp eax, 00000000h ; W8
    jnz notW8

    mov eax, W8 - EntryPoint
    jmp end_

notW8
    cmp eax, 00004000h ; XP
    jnz notXP

    mov eax, XP - EntryPoint
    jmp end_

notXP: ; 08004000h
    mov eax, W7 - EntryPoint

end_:

reloc31:
    add eax, EntryPoint

    push eax

reloc42:
    call [__imp__printf]
    add esp, 1 * 4

    push 0
reloc52:
    call [__imp__ExitProcess]
_c

msg db ' * OS detection via relocations type 4+(9^10): ', 0

W7 db "Windows 7", 0ah, 0
W8 db "Windows 8", 0ah, 0
XP db "Windows XP", 0ah, 0

align FILEALIGN * 8, db 0
