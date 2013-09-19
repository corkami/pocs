; a PE using relocation type 4 (W8 takes the parameter into account)

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 0ffff0000h ; <==
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

%include 'section_1fa.inc'

;*******************************************************************************
EntryPoint:
relocbase:
reloc22:
    push dword [relocme2]
reloc32:
    push dword [relocme1]
reloc41:
    push msg
reloc52:
    call [__imp__printf]
    add esp, 3 * 4
    push 0
reloc62:
    call [__imp__ExitProcess]
_c

relocme1 dd 0
relocme2 dd 0
msg db " * relocation type 4 according to its parameter: 0000:%08X ffff:%08X", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

Directory_Entry_Basereloc: ;****************************************************
block_start0:
    .VirtualAddress dd relocbase - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc22 + 2 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc32 + 2 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc41 + 1 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc52 + 2 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc62 + 2 - relocbase)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

block_start1:
    .VirtualAddress dd relocbase - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK1
    dw (IMAGE_REL_BASED_HIGHADJ << 12) | (relocme1 - relocbase),  0
    dw (IMAGE_REL_BASED_HIGHADJ << 12) | (relocme2 - relocbase), -1
BASE_RELOC_SIZE_OF_BLOCK1 equ $ - block_start1

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0
