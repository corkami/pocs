; a PE that calls imports by comparing kernel32 timestamp with known list

; inspired by Gynvael Coldwind's http://gynvael.coldwind.pl/n/windows_ret_addr

; Ange Albertini, BSD LICENCE 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

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
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
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

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    mov eax, [esp]
    and eax, 0ffff0000h

scanMZ
    sub eax, 10000h
    cmp dword [eax], 00905a4dh
    jnz scanMZ

    mov [K32IB], eax
    mov ebx, eax

    add eax, 3ch
    mov eax, [eax]
    add ebx, eax

    cmp dword [ebx], 00004550h
    jnz end_

foundPE
    add ebx, 8
    mov ebx, dword [ebx]

    mov ecx, table

scan_stamps
    mov eax, [ecx]
    cmp eax, ebx
    jg end_
    je found
    add ecx, 3 * 4
    jmp scan_stamps

found
    add ecx, 4 ; reaching LoadLibraryA address
    push ecx

    push msvcrt.dll
    mov ebx, [ecx]
    add ebx, [K32IB]
    call ebx

    pop ecx
    add ecx, 4 ; reaching GetProcAdddress address

    push printf
    push eax

    mov ebx, [ecx]
    add ebx, [K32IB]
    call ebx

    push Msg
    call eax
    add esp, 1 * 4

end_
    retn ; lazy :p
_c

Msg db " * a PE using hardcoded imports calls", 0ah, 0
msvcrt.dll db 'msvcrt.dll', 0
printf db 'printf', 0
_d

K32IB dd 0

; kernel32's timestamp, LoadLibraryA's RVA, GetProcAddress's RVA
table
    dd 02c4865a0h, 010930h, 010f60h
    dd 02e67e68dh, 0109deh, 0110cbh
    dd 02ff48837h, 007433h, 006c18h
    dd 0320c1ca0h, 007577h, 006d5ch
    dd 03546abb0h, 0076d4h, 006dach
    dd 0371fc2b3h, 0076d0h, 006da8h
    dd 0393f3c0eh, 0076a8h, 006d80h
    dd 03d6dfa28h, 01d961h, 01b332h
    dd 04802a12ch, 001d7bh, 00ae30h
    dd 049c4f482h, 001d7bh, 00ae40h
    dd 04a5bdaadh, 052864h, 051837h
    dd 04e211318h, 0149a7h, 011222h
    dd 05010a83ah, 0028ach, 001d30h
    dd 0503275b9h, 04dc65h, 04cc94h
    dd 050327671h, 0149bfh, 011222h
    dd 0

align FILEALIGN, db 0

; python script to dump data manually

; import sys, glob, pefile
; fn = "c:\\windows\\system32\\kernel32.dll" if len(sys.argv) == 1 else sys.argv[1]

; for f in glob.glob(fn):
; 	print f
; 	pe = pefile.PE(f)
; 	for sym in pe.DIRECTORY_ENTRY_EXPORT.symbols:
; 		if sym.name == "GetProcAddress":
; 			GPA = sym.address
; 		if sym.name == "LoadLibraryA":
; 			LLA = sym.address
; 	print "    dd 0%08xh, 0%05xh, 0%05xh" % (pe.FILE_HEADER.TimeDateStamp, LLA, GPA)
