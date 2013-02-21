; a PE32+ with no data directory, resolving imports manually

; Ange Albertini, BSD LICENCE 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 64

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
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_AMD64
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER64
    at IMAGE_OPTIONAL_HEADER64.Magic,                     dw IMAGE_NT_OPTIONAL_HDR64_MAGIC
    at IMAGE_OPTIONAL_HEADER64.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.ImageBase,                 dq IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER64.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER64.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER64.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER64.NumberOfRvaAndSizes,       dd 0
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
; TODO: port my own export parser to 64b
;------------------------------------------------------------------------------
; from http://blog.harmonysecurity.com/2009/08/calling-api-functions.html

  cld                    ; clear the direction flag
  and rsp, 0FFFFFFF0h    ; Ensure RSP is 16 byte aligned
  call start             ; call start, this pushes the address of 'api_call' onto the stack
delta:

api_call:
  push r9                  ; Save the 4th parameter
  push r8                  ; Save the 3rd parameter
  push rdx                 ; Save the 2nd parameter
  push rcx                 ; Save the 1st parameter
  push rsi                 ; Save RSI
  xor rdx, rdx             ; Zero rdx
  mov rdx, [gs:rdx+96]     ; Get a pointer to the PEB
  mov rdx, [rdx+24]        ; Get PEB->Ldr
  mov rdx, [rdx+32]        ; Get the first module from the InMemoryOrder module list
  next_mod:
  mov rsi, [rdx+80]        ; Get pointer to modules name (unicode string)
  movzx rcx, word [rdx+74] ; Set rcx to the length we want to check
  xor r9, r9               ; Clear r9 which will store the hash of the module name
loop_modname:
  xor rax, rax             ; Clear rax
  lodsb                    ; Read in the next byte of the name
  cmp al, 'a'              ; Some versions of Windows use lower case module names
  jl not_lowercase
  sub al, 0x20             ; If so normalise to uppercase
not_lowercase:
  ror r9d, 13              ; Rotate right our hash value
  add r9d, eax             ; Add the next byte of the name
  loop loop_modname        ; Loop untill we have read enough
  ; We now have the module hash computed
  push rdx                 ; Save the current position in the module list for later
  push r9                  ; Save the current module hash for later
  ; Proceed to itterate the export address table,
  mov rdx, [rdx+32]        ; Get this modules base address
  mov eax, dword [rdx+60]  ; Get PE header
  add rax, rdx             ; Add the modules base address
  mov eax, dword [rax+136] ; Get export tables RVA
  test rax, rax            ; Test if no export address table is present
  jz get_next_mod1         ; If no EAT present, process the next module
  add rax, rdx             ; Add the modules base address
  push rax                 ; Save the current modules EAT
  mov ecx, dword [rax+24]  ; Get the number of function names
  mov r8d, dword [rax+32]  ; Get the rva of the function names
  add r8, rdx              ; Add the modules base address
  ; Computing the module hash + function hash
get_next_func:
  jrcxz get_next_mod       ; When we reach the start of the EAT (we search backwards), process the next module
  dec rcx                  ; Decrement the function name counter
  mov esi, dword [r8+rcx*4]; Get rva of next module name
  add rsi, rdx             ; Add the modules base address
  xor r9, r9               ; Clear r9 which will store the hash of the function name
  ; And compare it to the one we want
loop_funcname:
  xor rax, rax             ; Clear rax
  lodsb                    ; Read in the next byte of the ASCII function name
  ror r9d, 13              ; Rotate right our hash value
  add r9d, eax             ; Add the next byte of the name
  cmp al, ah               ; Compare AL (the next byte from the name) to AH (null)
  jne loop_funcname        ; If we have not reached the null terminator, continue
  add r9, [rsp+8]          ; Add the current module hash to the function hash
  cmp r9d, r10d            ; Compare the hash to the one we are searchnig for
  jnz get_next_func        ; Go compute the next function hash if we have not found it
  ; If found, fix up stack, call the function and then value else compute the next one...
  pop rax                  ; Restore the current modules EAT
  mov r8d, dword [rax+36]  ; Get the ordinal table rva
  add r8, rdx              ; Add the modules base address
  mov cx, [r8+2*rcx]       ; Get the desired functions ordinal
  mov r8d, dword [rax+28]  ; Get the function addresses table rva
  add r8, rdx              ; Add the modules base address
  mov eax, dword [r8+4*rcx]; Get the desired functions RVA
  add rax, rdx             ; Add the modules base address to get the functions actual VA
  ; We now fix up the stack and perform the call to the drsired function...
finish:
  pop r8                   ; Clear off the current modules hash
  pop r8                   ; Clear off the current position in the module list
  pop rsi                  ; Restore RSI
  pop rcx                  ; Restore the 1st parameter
  pop rdx                  ; Restore the 2nd parameter
  pop r8                   ; Restore the 3rd parameter
  pop r9                   ; Restore the 4th parameter
  pop r10                  ; pop off the return address
  sub rsp, 32              ; reserve space for the four register params (4 * sizeof(QWORD) = 32)
                           ; It is the callers responsibility to restore RSP if need be (or alloc more space or align RSP).
  push r10                 ; push back the return address
  jmp rax                  ; Jump into the required function
  ; We now automagically return to the correct caller...
get_next_mod:              ;
  pop rax                  ; Pop off the current (now the previous) modules EAT
get_next_mod1:
  pop r9                   ; Pop off the current (now the previous) modules hash
  pop rdx                  ; Restore our position in the module list
  mov rdx, [rdx]           ; Get the next module
  jmp next_mod             ; Process this module


start:
  pop rbp                ; pop off the address of 'api_call' for calling later

  mov rdx, 1             ; param 2 is the command show parameter
  lea rcx, [rbp+command-delta] ; param 1 is the address to the command line

  mov r10d, 0x876F8B31   ; R10 = the hash value for WinExec
  call rbp               ; WinExec( &command, 1 );

  mov rcx, 0             ; set the exit function parameter
  mov r10d, 0x6F721347   ; R10 = the hash value for RtlExitUserThread
  call rbp               ; call ntdll.dll!RtlExitUserThread( 0 )

command:
  db "calc.exe", 0
_c

;------------------------------------------------------------------------------

Msg db " * a standard PE32+ (imports, standard alignments)", 0ah, 0
_d

align FILEALIGN, db 0
