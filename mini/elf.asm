; a mini ELF

; Ange Albertini, BSD Licence 2014-2017

BITS 32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EI_NIDENT equ 16

struc Elf32_Ehdr
    .e_ident     resb EI_NIDENT
    .e_type      resw 1
    .e_machine   resw 1
    .e_version   resd 1
    .e_entry     resd 1
    .e_phoff     resd 1
    .e_shoff     resd 1
    .e_flags     resd 1
    .e_ehsize    resw 1
    .e_phentsize resw 1
    .e_phnum     resw 1
    .e_shentsize resw 1
    .e_shnum     resw 1
    .e_shstrndx  resw 1
endstruc

struc Elf32_Phdr
    .p_type   resd 1
    .p_offset resd 1
    .p_vaddr  resd 1
    .p_paddr  resd 1
    .p_filesz resd 1
    .p_memsz  resd 1
    .p_flags  resd 1
    .p_align  resd 1
endstruc

ELFCLASS32 equ 1

ELFDATA2LSB equ 1

EV_CURRENT equ 1

ET_EXEC equ 2

EM_386 equ 3

PT_LOAD equ 1

PF_X equ 1
PF_R equ 4

SC_EXIT equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ELFBASE equ 08000000h

org ELFBASE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ELF Header

segment_start:

ehdr:
istruc Elf32_Ehdr
    at Elf32_Ehdr.e_ident
        EI_MAG     db 07Fh, "ELF"
        EI_CLASS   db ELFCLASS32
        EI_DATA    db ELFDATA2LSB
        EI_VERSION db EV_CURRENT
    at Elf32_Ehdr.e_type,      dw ET_EXEC
    at Elf32_Ehdr.e_machine,   dw EM_386
    at Elf32_Ehdr.e_version,   dd EV_CURRENT
    at Elf32_Ehdr.e_entry,     dd entry
    at Elf32_Ehdr.e_phoff,     dd phdr - ehdr
    at Elf32_Ehdr.e_ehsize,    dw Elf32_Ehdr_size
    at Elf32_Ehdr.e_phentsize, dw Elf32_Phdr_size
    at Elf32_Ehdr.e_phnum,     dw PHNUM
iend
align 16, db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Program header table

phdr:
istruc Elf32_Phdr
    at Elf32_Phdr.p_type,   dd PT_LOAD
    at Elf32_Phdr.p_offset, dd segment_start - ehdr
    at Elf32_Phdr.p_vaddr,  dd ELFBASE
    at Elf32_Phdr.p_paddr,  dd ELFBASE
    at Elf32_Phdr.p_filesz, dd SEGMENT_SIZE
    at Elf32_Phdr.p_memsz,  dd SEGMENT_SIZE
    at Elf32_Phdr.p_flags,  dd PF_R + PF_X
iend
PHNUM equ ($ - phdr) / Elf32_Phdr_size

align 16, db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .text section (code)

text:
entry:
    mov ebx, 42 ; return code

    mov eax, SC_EXIT
    int 80h

TEXT_SIZE equ $ - text

align 16, db 0

SEGMENT_SIZE equ $ - segment_start
