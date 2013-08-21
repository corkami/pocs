; a DLL with MEM_SHARED section - just a holder for a single dword of shared data 

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers_dll.inc'

istruc IMAGE_DATA_DIRECTORY_16
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_WRITE | IMAGE_SCN_MEM_SHARED ; <==
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN ;**************

SharedCounter dd 0

EntryPoint:
    inc eax
    retn 3 * 4
_c

;*******************************************************************************

align FILEALIGN, db 0
