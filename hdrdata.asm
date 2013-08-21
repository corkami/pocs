; a PE with data between header and first section

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

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

db "this will not be in memory, as it's between the declared header and before the first section"

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    mov eax, SIZEOFHEADERS + IMAGEBASE
    mov ebx, dword [eax]
    cmp ebx, 'this'
    jz error_
_
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
error_:
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * a PE with data between header and first section", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0
