; a PE as simple as possible, definition-wise

; Ange Albertini, BSD LICENCE 2012-2017

; *****************************************************************************

struc IMAGE_DOS_HEADER
    .e_magic      resw 1
    .e_cblp       resw 1
    .e_cp         resw 1
    .e_crlc       resw 1
    .e_cparhdr    resw 1
    .e_minalloc   resw 1
    .e_maxalloc   resw 1
    .e_ss         resw 1
    .e_sp         resw 1
    .e_csum       resw 1
    .e_ip         resw 1
    .e_cs         resw 1
    .e_lfarlc     resw 1
    .e_ovno       resw 1
    .e_res        resw 4
    .e_oemid      resw 1
    .e_oeminfo    resw 1
    .e_res2       resw 10
    .e_lfanew     resd 1
endstruc

struc IMAGE_NT_HEADERS
    .Signature       resd 1
;   .FileHeader      resb IMAGE_FILE_HEADER_size
;   .OptionalHeader  resb IMAGE_OPTIONAL_HEADER32_size
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

IMAGE_FILE_MACHINE_I386       equ 0014ch
IMAGE_FILE_EXECUTABLE_IMAGE   equ 00002h
IMAGE_NT_OPTIONAL_HDR32_MAGIC equ 0010bh
IMAGE_SUBSYSTEM_WINDOWS_CUI   equ 00003h

; *****************************************************************************

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1
FILEALIGN equ 1

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS                 
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend

istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,         dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.Characteristics, dw IMAGE_FILE_EXECUTABLE_IMAGE
iend

istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE ; not required in older Windows
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE ; not required under XP
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd EntryPoint - IMAGEBASE ; required for W8
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
iend
istruc IMAGE_DATA_DIRECTORY_16
iend

align 16, db 0 ; for nicer visual representation

EntryPoint:
    mov eax, 42
    retn

;required padding
times 160h - 146h db 0

SIZEOFIMAGE equ $ - IMAGEBASE
