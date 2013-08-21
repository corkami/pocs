; non-PE EXE with with reversed signature

; Ange Albertini, BSD Licence, 2010-2013

%include 'consts.inc'

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,   db 'ZM'
;   at IMAGE_DOS_HEADER.e_cblp,    db LAST_BYTE   ; not required
    at IMAGE_DOS_HEADER.e_cp,      dw PAGES
    at IMAGE_DOS_HEADER.e_cparhdr, dw dos_stub >> 4

; code start must be paragraph-aligned
align 10h, db 0
dos_stub:
    push    cs
    pop     ds
    jmp next

; those 2 needs specific values
    at IMAGE_DOS_HEADER.e_ip, dw 0
    at IMAGE_DOS_HEADER.e_cs, dw 0
dos_msg:
    db ' * EXE with ZM signature', 0ah, '$'

next:
    mov     dx, dos_msg - dos_stub
    mov     ah, 9
    int     21h
    mov     ax, 4c01h
    int     21h
iend


PAGES equ $ >> 6
LAST_BYTE equ $

;align 10h, db 0 ; not required, we could even remove the last 2 zeroes
