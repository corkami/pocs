; a non-null data PE with executed code

; Ange Albertini, BSD Licence, 2012-2013

db 'MZ'
align 3bh, db 1
	dd NT_HEADER
align 10h, db 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;same as "incbin 'w32-exec-calc-shellcode.bin'"  from skylined but with a retn opcode to avoid crash
bits 32
    xor edx, edx
    push    edx
    push    'SC  ' ; executing SC.exe instead of calc.exe
    mov     esi, esp
    push    edx
    push    esi

    mov     esi, [fs:edx + 0x30]
    mov     esi, [esi + 0x0c]
    mov     esi, [esi + 0x0c]
    lodsd
    mov     esi, [eax]
    mov     edi, [esi + 0x18]

    mov     ebx, [edi + 0x3c]
    mov     ebx, [edi + ebx + 0x78]

    mov     esi, [edi + ebx + 0x20]
    add     esi, edi

    mov     ecx, [edi + ebx + 0x24]
    add     ecx, edi

find_winexec_x86:
    inc     edx
    lodsd
    cmp     dword [edi + eax], 'WinE'
    jne     find_winexec_x86

    movzx   edx, word [ecx + edx * 2 - 2]

    mov     esi, [edi + ebx + 0x1c]
    add     esi, edi
    add     edi, [esi + edx * 4]

    call    edi

    add esp, 2 * 4
    retn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

times 01010101h - 8eh db 1
NT_HEADER:
	db 'PE'