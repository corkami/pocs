; a PE with unused corrupted relocations

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

%include "nthd_std.inc"

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE + 2000h ; <=
iend

%include 'section_1fa.inc'

EntryPoint:
reloc01:
    push Msg
reloc22:
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
reloc31:
    call [__imp__ExitProcess]
_c

Msg db " * a PE with corrupted fake relocations", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

Directory_Entry_Basereloc:
block_start0:
    .VirtualAddress dd reloc01 - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0 + 1000h ; <=
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc22 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc31 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | 0ffh
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (block_start0 - reloc01)
    dw 0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (here - reloc01)
    dw 0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (here - reloc01)
here:
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (here - reloc01)
    dw 0
    
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0
