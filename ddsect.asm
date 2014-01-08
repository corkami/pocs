; a PE with a section table in its data directory
; suggested by ap0x

; Ange Albertini, BSD LICENCE 2014

%include 'consts.inc'

%include 'headers.inc'

exports_   dd 0, 0
imports_   dd Import_Descriptor - IMAGEBASE, 0
resources_ dd 0, 0
exception_ dd 0, 0
security_  dd 0, 0
relocs_    dd 0, 0
SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
; debug included in section names
    dd 0, 0
;architecture
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
;globalptr
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
;tls
    dd 0, 0
;LoadConfig size
    dd 0
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

%include 'code_printf.inc'

Msg db " * a PE with a section table in its data directory", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0
