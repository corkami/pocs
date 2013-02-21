;this is a type-able PE quine PE:
;a working PE file, made entirely in assembly, with no need of a compiler, with its own source embedded, which it displays on execution, via 'typing' its own binary.
;you can do it manually via 'type quine.exe'.

;Ange Albertini, BSD Licence, 2011

IMAGEBASE equ 400000h

db 'MZ'
align 3bh, db 0dh
dd nt_header - IMAGEBASE
    db 0dh

incbin 'quine.asm'
db 1ah

op db "open", 0
fn db "cmd", 0
param db "/K type quine.exe", 0

; required for self-contained aspects
struc IMAGE_NT_HEADERS
  .Signature         resd 1
endstruc

struc IMAGE_FILE_HEADER
  .Machine              resw 1
  .NumberOfSections     resw 1
  .TimeDateStamp        resd 1
  .PointerToSymbolTable resd 1
  .NumberOfSymbols      resd 1
  .SizeOfOptionalHeader resw 1
  .Characteristics      resw 1
endstruc

struc IMAGE_OPTIONAL_HEADER32
  .Magic                        resw 1
  .MajorLinkerVersion           resb 1
  .MinorLinkerVersion           resb 1
  .SizeOfCode                   resd 1
  .SizeOfInitializedData        resd 1
  .SizeOfUninitializedData      resd 1
  .AddressOfEntryPoint          resd 1
  .BaseOfCode                   resd 1
  .BaseOfData                   resd 1
  .ImageBase                    resd 1
  .SectionAlignment             resd 1
  .FileAlignment                resd 1
  .MajorOperatingSystemVersion  resw 1
  .MinorOperatingSystemVersion  resw 1
  .MajorImageVersion            resw 1
  .MinorImageVersion            resw 1
  .MajorSubsystemVersion        resw 1
  .MinorSubsystemVersion        resw 1
  .Win32VersionValue            resd 1
  .SizeOfImage                  resd 1
  .SizeOfHeaders                resd 1
  .CheckSum                     resd 1
  .Subsystem                    resw 1
  .DllCharacteristics           resw 1
  .SizeOfStackReserve           resd 1
  .SizeOfStackCommit            resd 1
  .SizeOfHeapReserve            resd 1
  .SizeOfHeapCommit             resd 1
  .LoaderFlags                  resd 1
  .NumberOfRvaAndSizes          resd 1
  .DataDirectory                resb 0
endstruc

struc IMAGE_DATA_DIRECTORY_16
    .ExportsVA        resd 1
    .ExportsSize      resd 1
    .ImportsVA        resd 1
    .ImportsSize      resd 1
    .ResourceVA       resd 1
    .ResourceSize     resd 1
    .Exception        resd 2
    .Security         resd 2
    .FixupsVA         resd 1
    .FixupsSize       resd 1
    .DebugVA          resd 1
    .DebugSize        resd 1
    .Description      resd 2
    .MIPS             resd 2
    .TLSVA            resd 1
    .TLSSize          resd 1
    .Load             resd 2
    .BoundImportsVA   resd 1
    .BoundImportsSize resd 1
    .IATVA            resd 1
    .IATSize          resd 1
    .DelayImportsVA   resd 1
    .DelayImportsSize resd 1
    .COM              resd 2
    .reserved         resd 2
endstruc

struc IMAGE_SECTION_HEADER
    .Name                    resb IMAGE_SIZEOF_SHORT_NAME
    .VirtualSize             resd 1
    .VirtualAddress          resd 1
    .SizeOfRawData           resd 1
    .PointerToRawData        resd 1
    .PointerToRelocations    resd 1
    .PointerToLinenumbers    resd 1
    .NumberOfRelocations     resw 1
    .NumberOfLinenumbers     resw 1
    .Characteristics         resd 1
endstruc

IMAGE_SIZEOF_SHORT_NAME equ 8
IMAGE_SCN_MEM_EXECUTE            equ 020000000h
IMAGE_SCN_MEM_WRITE              equ 080000000h

IMAGE_FILE_MACHINE_I386         equ 014ch
IMAGE_NT_OPTIONAL_HDR32_MAGIC equ 010bh

IMAGE_FILE_RELOCS_STRIPPED         equ 00001h
IMAGE_FILE_EXECUTABLE_IMAGE        equ 00002h
IMAGE_FILE_LINE_NUMS_STRIPPED      equ 00004h
IMAGE_FILE_LOCAL_SYMS_STRIPPED     equ 00008h
IMAGE_FILE_32BIT_MACHINE           equ 00100h


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FILEALIGN equ 4h
SECTIONALIGN equ FILEALIGN
org IMAGEBASE

align 4, db 0
nt_header:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic                    , dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint      , dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase                , dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment         , dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment            , dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion    , dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage              , dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders            , dd SIZEOFHEADERS  ; can be 0 in some circumstances
    at IMAGE_OPTIONAL_HEADER32.Subsystem                , dw 2
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes      , dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd IMPORT_DESCRIPTOR - IMAGEBASE
iend

NUMBEROFRVAANDSIZES equ 16

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualAddress, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics, dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align FILEALIGN, db 0
align 1000h, db 0           ; necessary under Win7
SIZEOFHEADERS equ $ - IMAGEBASE

bits 32
Section0Start:

EntryPoint:
    push 1
    push 0
    push param
    push fn
    push op
    push 0
    call [ShellExecuteA]

    push 0
    call [ExitProcess]

kernel32.dll_iat:
ExitProcess:
    DD hnExitProcess - IMAGEBASE
    DD 0

shell32.dll_iat:
ShellExecuteA:
    DD hnShellExecuteA - IMAGEBASE
    DD 0

IMPORT_DESCRIPTOR:
kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0
    dd 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE

shell32.dll_DESCRIPTOR:
    dd shell32.dll_hintnames - IMAGEBASE
    dd 0
    dd 0
    dd shell32.dll - IMAGEBASE
    dd shell32.dll_iat - IMAGEBASE

    times 5 dd 0

HintNames:
kernel32.dll_hintnames:
    DD hnExitProcess - IMAGEBASE
    DD 0

shell32.dll_hintnames:
    DD hnShellExecuteA - IMAGEBASE
    DD 0

kernel32.dll  DB 'kernel32.dll',0
shell32.dll  DB 'shell32.dll',0

hnShellExecuteA:
    dw 0
    db 'ShellExecuteA',0

hnExitProcess:
    dw 0
    db 'ExitProcess',0


SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
