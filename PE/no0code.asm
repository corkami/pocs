; a PE with no null before code ends
; the PE headers are relocated far enough so that e_lfanew contains no 0

;Ange Albertini, BSD Licence, 2011

%include 'consts.inc'

IMAGEBASE equ 400000h

db 'MZ'
align 3bh, db 90h
dd nt_header - IMAGEBASE
    db 90h
EntryPoint:
bits 32
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;same as "incbin 'w32-exec-calc-shellcode.bin'"  from skylined but with a retn opcode to avoid crash
    xor   edx, edx
    push  edx
    push  'SC  ' ; executing SC.exe instead of calc.exe
    mov   esi, esp
    push  edx
    push  esi
          
    mov   esi, [fs:edx + 0x30]
    mov   esi, [esi + 0x0c]
    mov   esi, [esi + 0x0c]
    lodsd 
    mov   esi, [eax]
    mov   edi, [esi + 0x18]
          
    mov   ebx, [edi + 0x3c]
    mov   ebx, [edi + ebx + 0x78]
          
    mov   esi, [edi + ebx + 0x20]
    add   esi, edi
          
    mov   ecx, [edi + ebx + 0x24]
    add   ecx, edi

find_winexec_x86:
    inc   edx
    lodsd
    cmp   dword [edi + eax], 'WinE'
    jne   find_winexec_x86

    movzx edx, word [ecx + edx * 2 - 2]

    mov   esi, [edi + ebx + 0x1c]
    add   esi, edi
    add   edi, [esi + edx * 4]

    call  edi

    add esp, 2 * 4
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

times 01010000h db ' '
align 0010101h
FILEALIGN equ 4h
SECTIONALIGN equ 4
org IMAGEBASE

align 4, db 0dh
nt_header:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic                , dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint  , dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase            , dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment     , dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment        , dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage          , dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders        , dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem            , dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes  , dd 0
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

align FILEALIGN, db 0
align 1000h, db 0           ; necessary under Win7
SIZEOFHEADERS equ $ - IMAGEBASE

times 4 db 0
SIZEOFIMAGE equ $ - IMAGEBASE
