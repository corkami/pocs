; a tiny data PE

; Ange Albertini, BSD Licence, 2012-2013

; modified structure, with shortened e_lfanew
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
    .e_lfanew     resb 1 ; <=== truncated here
endstruc

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'

NT_SIGNATURE db 'PE', 0, 0
db ' * tiny data PE (61 bytes)', 0dh, 0ah, 0
    at IMAGE_DOS_HEADER.e_lfanew, db NT_SIGNATURE
iend
