checksum dd 0
ImageBase dd 0
char db 0
ExportDirectory dd 0

GetProcAddress_Hash:
    mov [ebp + ImageBase - base], eax
    mov [ebp + checksum - base], ebx
    mov ecx, [ebp + ImageBase - base]
    ; ecx = PE start / ImageBase
    mov edx, [ecx + IMAGE_DOS_HEADER.e_lfanew] ; e_lfanew = RVA of NT_SIGNATURE
    add edx, [ebp + ImageBase - base]    ; RVA to VA
        ; => eax = NT_SIGNATURE VA

    mov edx, [edx + IMAGE_NT_HEADERS_size + \
                    IMAGE_FILE_HEADER_size + \
                    IMAGE_OPTIONAL_HEADER32_size]  ; IMAGE_DIRECTORY_ENTRY_EXPORT (.RVA) - NT_SIGNATURE
    add edx, [ebp + ImageBase - base]    ; RVA to VA
        ; => edx = IMAGE_DIRECTORY_ENTRY_EXPORT VA
    mov [ebp + ExportDirectory - base], edx

    mov ecx, [edx + IMAGE_EXPORT_DIRECTORY.NumberOfNames] ; NumberOfNames

    mov ebx, [edx + IMAGE_EXPORT_DIRECTORY.AddressOfNames] ; AddressOfNames
    add ebx, [ebp + ImageBase - base]    ; RVA to VA
_
next_name:
    test ecx, ecx
    jz no_more_exports
    dec ecx

    mov esi, [ebx + ecx * 4]
    add esi, [ebp + ImageBase - base] ; RVA to VA

    mov edi, 0
_
checksum_loop:
    xor eax, eax
    lodsb

    rol edi, 7
    add edi, eax

    test al, al
    jnz checksum_loop

    cmp edi, [ebp + checksum - base]
    jnz next_name

    mov ebx, [edx + IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals] ; AddressOfNamesOrdinal RVA
    add ebx, [ebp + ImageBase - base]

    mov cx, [ebx + ecx * 2]

    mov ebx, [edx + IMAGE_EXPORT_DIRECTORY.AddressOfFunctions] ; AddressOfFunctions RVA
    add ebx, [ebp + ImageBase - base]
    mov ebx, [ebx + ecx * 4] ; Functions RVA
    add ebx, [ebp + ImageBase - base]

    jmp _end
_
no_more_exports:
    xor ebx, ebx
_
_end:
    retn
_c
