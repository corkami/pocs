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
reloc11:
    mov esi, tests + (TESTCOUNT * 4) - 4
    mov ecx, TESTCOUNT
    std
_next:
    lodsd
    push eax
    dec ecx
    jnz _next

reloc21:
    push msg
    cld
reloc32:
    call [__imp__printf]
    add esp, (TESTCOUNT + 1) * 4
    push 0
reloc42:
    call [__imp__ExitProcess]
_c

tests:
    dd 0
    dd 080000000h
    dd 0ffffffffh
    dd 0
    dd 080000000h
    dd 0ffffffffh
TESTCOUNT equ ($ - tests) / 4

msg db " * relocation type 4 (value/param)", 0ah
db "  00000000/0000:%08x", 0ah
db "  80000000/0000:%08x", 0ah
db "  ffffffff/0000:%08x", 0ah
db "  00000000/ffff:%08x", 0ah
db "  80000000/ffff:%08x", 0ah
db "  ffffffff/ffff:%08x", 0ah
db 0
_d

%include 'imports_printfexitprocess.inc'

Directory_Entry_Basereloc: ;****************************************************
block_start0:
    .VirtualAddress dd EntryPoint - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc11 + 1 - EntryPoint)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc21 + 1 - EntryPoint)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc32 + 2 - EntryPoint)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - EntryPoint)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

block_start1:
    .VirtualAddress dd EntryPoint - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK1
    dw (IMAGE_REL_BASED_HIGHADJ << 12) | (tests + 0*4 - EntryPoint), 0
    dw (IMAGE_REL_BASED_HIGHADJ << 12) | (tests + 1*4 - EntryPoint), 0
    dw (IMAGE_REL_BASED_HIGHADJ << 12) | (tests + 2*4 - EntryPoint), 0
    dw (IMAGE_REL_BASED_HIGHADJ << 12) | (tests + 3*4 - EntryPoint), -1
    dw (IMAGE_REL_BASED_HIGHADJ << 12) | (tests + 4*4 - EntryPoint), -1
    dw (IMAGE_REL_BASED_HIGHADJ << 12) | (tests + 5*4 - EntryPoint), -1
BASE_RELOC_SIZE_OF_BLOCK1 equ $ - block_start1

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0
