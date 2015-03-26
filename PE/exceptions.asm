; a 64b PE using an Exception directory

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers64.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Exception, dd Exception - IMAGEBASE, EXCEPTION_SIZE
iend

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

;*******************************************************************************

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

handler:
    lea ecx, [Msg]
    call [__imp__printf]
    xor ecx, ecx
    call [__imp__ExitProcess]
_c

Msg db " * a 64b PE making use of an Exception DataDirectory", 0ah, 0
_d

EntryPoint:
    sub rsp, 8 * 5
    int3
EndCode:

%include 'imports_printfexitprocess64.inc'

Exception: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
istruc RUNTIME_FUNCTION
    at RUNTIME_FUNCTION.FunctionStart, dd EntryPoint - IMAGEBASE
    at RUNTIME_FUNCTION.FunctionEnd  , dd EndCode - IMAGEBASE
    at RUNTIME_FUNCTION.UnwindInfo   , dd UnwindData - IMAGEBASE
iend
EXCEPTION_SIZE equ $ - Exception

UnwindData:
istruc UNWIND_INFO
    at UNWIND_INFO.Ver3_Flags     , db 1 + (UNW_FLAG_EHANDLER << 3)
    at UNWIND_INFO.CntUnwindCodes , db 0 ; let's shrink it to the minimum
iend
align 4, db 0
    dd handler - IMAGEBASE ; 1 exception handler
    dd 0                   ; handler data

align FILEALIGN, db 0
