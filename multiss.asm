; a multi-subsystem PE (that displays a message) no matter what its subsystem is set to.

; Ange Albertini, BSD LICENCE 2011

%include 'consts.inc'

IMAGEBASE EQU 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 200h
FILEALIGN equ SECTIONALIGN

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 3 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw 0 ; to make a neutral main file
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 2 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 2 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

;******************************************************************************

EntryPoint:
    pushad
_
    mov eax, cs
    cmp eax, 8
    jz driver

    cmp eax, 1bh
    jz usermode

    jmp oh_merde
_c

;******************************************************************************

DBGPRINT equ 072015887h

driver:
    ; not reliable on multicore
    ;mov eax, [fs:034h]
    ;mov eax, [eax + 010h]

    mov ecx,176h
    rdmsr

    and ax,0f001h
scan_loop:
    dec eax
    cmp dword [eax],00905a4dh
    jnz scan_loop
_
    mov ebx, DBGPRINT
    call GetProcAddress_Hash

reloc01:
    push msgdriver
    call ebx
    add esp, 1 * 4
_
oh_merde:
    popad
_
    mov eax, 0xC0000182; STATUS_DEVICE_CONFIGURATION_ERROR
    retn 8
_c

msgdriver db " * multisystem PE (driver)", 0
_d

;******************************************************************************

usermode:
    call ring3start

    push aGetConsoleWindow
    push dword [hKernel32]
    call [GetProcAddress]

    call eax
    test eax, eax
    jz GUI
    jmp CUI
_c

aGetConsoleWindow db 'GetConsoleWindow', 0
_d

;******************************************************************************

LOADLIBRARYA equ 06FFFE488h
GETPROCADDRESS equ 03F8AAA7Eh

ring3start:
    mov eax,[fs:030h]   ; _TIB.PebPtr
    mov eax,[eax + 0ch] ; _PEB.Ldr
    mov eax,[eax + 0ch] ; _PEB_LDR_DATA.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax + 18h] ; _LDR_MODULE.BaseAddress

;   brutal way, not as much compatible
;   mov eax, [esp + 4]
;   and eax, 0fff00000h

    mov [hKernel32], eax

    mov eax, [hKernel32]
    mov ebx, LOADLIBRARYA
    call GetProcAddress_Hash
    mov [LoadLibraryA], ebx

    mov eax, [hKernel32]
    mov ebx, GETPROCADDRESS
    call GetProcAddress_Hash
    mov [GetProcAddress], ebx

    retn
_c
hKernel32 dd 0
LoadLibraryA dd 0
GetProcAddress dd 0

;******************************************************************************

CUI:
    push amsvcrt
    call [LoadLibraryA]
_
    push aprintf
    push eax
    call [GetProcAddress]
_
    push msgcui
    call eax
    add esp, 1 * 4
_
    popad
    retn
_c

amsvcrt db 'msvcrt.dll', 0
aprintf db 'printf', 0
msgcui db ' * multisystem PE (console)', 0
_d

;******************************************************************************

GUI:
    push auser32
    call [LoadLibraryA]
_
    push aMessageBoxA
    push eax
    call [GetProcAddress]
_
    push 40h
    push aTada
    push msggui
    push 0
    call eax
_
    popad
    retn
_c

aFreeConsole db 'FreeConsole', 0
auser32 db 'user32.dll', 0
aMessageBoxA db 'MessageBoxA', 0
aTada db 'multisystem PE', 0
msggui db '(GUI)', 0
_d

;******************************************************************************

DOS_HEADER__e_lfanew equ 03ch

NT_SIGNATURE__IMAGE_DIRECTORY_ENTRY_EXPORT__RVA equ 78h

Exports__NumberOfNames      EQU 018h
Exports__AddressOfFunctions EQU 01ch
Exports__AddressOfNames     EQU 020h
Exports__AddressOfNamesOrdinal EQU 024h


GetProcAddress_Hash:
reloc21:
    mov [ImageBase], eax
reloc32:
    mov [checksum], ebx
reloc42:
    mov ebp, [ImageBase]
    ; ebp = PE start / ImageBase
    mov edx, [ebp + DOS_HEADER__e_lfanew] ; e_lfanew = RVA of NT_SIGNATURE
reloc52:
    add edx, [ImageBase]    ; RVA to VA
        ; => eax = NT_SIGNATURE VA

    mov edx, [edx + NT_SIGNATURE__IMAGE_DIRECTORY_ENTRY_EXPORT__RVA]  ; IMAGE_DIRECTORY_ENTRY_EXPORT (.RVA) - NT_SIGNATURE
reloc62:
    add edx, [ImageBase]    ; RVA to VA
        ; => edx = IMAGE_DIRECTORY_ENTRY_EXPORT VA

    mov ecx, [edx + Exports__NumberOfNames] ; NumberOfNames

    mov ebx, [edx + Exports__AddressOfNames] ; AddressOfNames
reloc72:
    add ebx, [ImageBase]    ; RVA to VA
_
next_name:
    test ecx, ecx
    jz no_more_exports
    dec ecx

    mov esi, [ebx + ecx * 4]
reloc82:
    add esi, [ImageBase] ; RVA to VA

    mov edi, 0
_
checksum_loop:
    xor eax, eax
    lodsb

    rol edi, 7
    add edi, eax

    test al, al
    jnz checksum_loop

reloc92:
    cmp edi, [checksum]
    jnz next_name

    mov ebx, [edx + Exports__AddressOfNamesOrdinal] ; AddressOfNamesOrdinal RVA
reloca2:
    add ebx, [ImageBase]

    mov cx, [ebx + ecx * 2]

    mov ebx, [edx + Exports__AddressOfFunctions] ; AddressOfFunctions RVA
relocb2:
    add ebx, [ImageBase]
    mov ebx, [ebx + ecx * 4] ; Functions RVA
relocc2:
    add ebx, [ImageBase]

    jmp _end
_
no_more_exports:
    xor ebx, ebx
_
_end:
    retn
_c

checksum dd 0
ImageBase dd 0
_d

;******************************************************************************

Directory_Entry_Basereloc:
block_start0:
    .VirtualAddress dd reloc01 - IMAGEBASE
    .SizeOfBlock dd base_reloc_size_of_block0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc21 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc32 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc42 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc52 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc62 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc72 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc82 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc92 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloca2 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (relocb2 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (relocc2 + 2 - reloc01)
    base_reloc_size_of_block0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc
_d

align FILEALIGN, db 0
