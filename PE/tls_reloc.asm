; relocated TLS

; Ange Albertini, BSD LICENCE 2009-2013

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
    at IMAGE_DATA_DIRECTORY_16.TLSVA,      dd Image_Tls_Directory32 - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    push 0
relocbase:
reloc02:
    call [__imp__ExitProcess]
_c

tls:
reloc12:
    mov dword [CallBacks], 0
reloc21:
    push msg
reloc32:
    call [__imp__printf]
    add esp, 1 * 4
    retn
_c

msg db " * relocated TLS", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'


Image_Tls_Directory32:
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex
reloc40:
    dd $ + 2 * 4
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks
reloc50:
        dd CallBacks
iend
_d

CallBacks:
reloc60:
    dd tls
    dd 0
_d

Directory_Entry_Basereloc: ;****************************************************
block_start0:
    .VirtualAddress dd relocbase - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc02 + 2 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc12 + 2 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc21 + 1 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc32 + 2 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc40 + 0 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc50 + 0 - relocbase)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc60 + 0 - relocbase)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

align FILEALIGN, db 0

