; a PE with the section table at the bottom of the PE

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'
%include 'dd_imports.inc'

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * section table at the bottom of the file", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

SIZEOFOPTIONALHEADER equ $ - OptionalHeader - (SECTIONALIGN - FILEALIGN)
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE - (SECTIONALIGN - FILEALIGN)

align FILEALIGN, db 0
