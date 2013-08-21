; a PE with the section table outside the PE, in appended data (but in the header itself, for XP compatibility)

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'
%include 'dd_imports.inc'

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

%include 'code_printf.inc'

Msg db " * section table in appended data", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0

SIZEOFOPTIONALHEADER equ $ - OptionalHeader - (SECTIONALIGN - FILEALIGN)
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE - (SECTIONALIGN - FILEALIGN)
