; a working Mach-O for optimal visual representation

; Ange Albertini 2013-2017

BITS 32

; *****************************************************************************

struc mach_header
    .magic      resd 1
    .cputype    resd 1
    .cpusubtype resd 1
    .filetype   resd 1
    .ncmds      resd 1
    .sizeofcmds resd 1
    .flags      resd 1
endstruc

MH_MAGIC equ    0FEEDFACEh

CPU_TYPE_X86    equ        7
CPU_TYPE_I386   equ CPU_TYPE_X86

CPU_SUBTYPE_I386_ALL equ         3

MH_EXECUTE  equ 2

struc segment_command
    .cmd      resd 1
    .cmdsize  resd 1
    .segname  resb 16
    .vmaddr   resd 1
    .vmsize   resd 1
    .fileoff  resd 1
    .filesize resd 1
    .maxprot  resd 1
    .initprot resd 1
    .nsects   resd 1
    .flags    resd 1
endstruc

LC_SEGMENT        equ         1
LC_UNIXTHREAD     equ         5


VM_PROT_READ    equ 1
VM_PROT_EXECUTE equ 4

    
struc section_
    .sectname  resb 16
    .segname   resb 16
    .addr      resd 1
    .size      resd 1
    .offset    resd 1
    .align     resd 1
    .reloff    resd 1
    .nreloc    resd 1
    .flags     resd 1
    .reserved1 resd 1
    .reserved2 resd 1
endstruc

struc thread_command
    .cmd     resd 1
    .cmdsize resd 1
    .flavor  resd 1
    .count   resd 1
;   .state ; starts here
endstruc

x86_THREAD_STATE_32 equ 1

struc i386_thread_state
    .eax    resd 1
    .ebx    resd 1
    .ecx    resd 1
    .edx    resd 1
    .edi    resd 1
    .esi    resd 1
    .ebp    resd 1
    .esp    resd 1
    .ss     resd 1
    .eflags resd 1
    .eip    resd 1
    .cs     resd 1
    .ds     resd 1
    .es     resd 1
    .fs     resd 1
    .gs     resd 1
endstruc

SC_EXIT equ 1
SC_WRITE equ 4h

; *****************************************************************************

istruc mach_header
    at mach_header.magic,       dd MH_MAGIC
    at mach_header.cputype,     dd CPU_TYPE_I386
    at mach_header.cpusubtype,  dd CPU_SUBTYPE_I386_ALL
    at mach_header.filetype,    dd MH_EXECUTE
    at mach_header.ncmds,       dd 2 ; segment, thread
    at mach_header.sizeofcmds,  dd CMD_SIZE
iend

commands:

textsc:
istruc segment_command
    at segment_command.cmd,      dd LC_SEGMENT
    at segment_command.cmdsize,  dd TEXTSC_SIZE
    at segment_command.vmaddr,   dd 0
    at segment_command.vmsize,   dd FILESIZE
    at segment_command.fileoff,  dd 0
    at segment_command.filesize, dd FILESIZE
    at segment_command.initprot, dd VM_PROT_READ + VM_PROT_EXECUTE
iend

TEXTSC_SIZE equ $ - textsc

tc:
istruc thread_command
    at thread_command.cmd,     dd LC_UNIXTHREAD
    at thread_command.cmdsize, dd TC_SIZE
    at thread_command.flavor,  dd x86_THREAD_STATE_32
    at thread_command.count,   dd i386_thread_state_size >> 2
iend

istruc i386_thread_state
    at i386_thread_state.eip, dd text
iend

TC_SIZE equ $ - tc

CMD_SIZE equ $ - commands

align 16, db 0

text:
    push byte 42 ; exit value
    mov  eax, SC_EXIT
    sub  esp, byte 4
    int  80h

TEXT_SIZE equ $ - text

align 16, db 0

FILESIZE equ $
