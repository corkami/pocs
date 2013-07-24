; a PE with many standard characteristics, as a standard 'have everything' PE

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 400000h

org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,    db 'MZ'
    at IMAGE_DOS_HEADER.e_cblp,     dw 090h
    at IMAGE_DOS_HEADER.e_cp,       dw 3
    at IMAGE_DOS_HEADER.e_cparhdr,  dw (dos_stub - IMAGEBASE) >> 4
    at IMAGE_DOS_HEADER.e_maxalloc, dw 0ffffh
    at IMAGE_DOS_HEADER.e_sp,       dw 0b8h
    at IMAGE_DOS_HEADER.e_lfarlc,   dw 040h
    at IMAGE_DOS_HEADER.e_lfanew,   dd NT_Signature - IMAGEBASE
iend

;*****************************

align 010h, db 0
dos_stub:
bits 16
    push    cs
    pop     ds
    mov     dx, dos_msg - dos_stub
    mov     ah, 9
    int     21h
    mov     ax, 4c01h
    int     21h
dos_msg
    db 'This program cannot be run in DOS mode.', 0dh, 0dh, 0ah, '$'

;*****************************

bits 32
align 16, db 0
RichHeader:
    dd "DanS" ^ RichKey     , 0 ^ RichKey, 0 ^ RichKey       , 0 ^ RichKey
    dd 0131f8eh ^ RichKey   , 7 ^ RichKey, 01220fch ^ RichKey, 1 ^ RichKey
    dd "Rich", 0 ^ RichKey  , 0, 0
align 16, db 0

;*****************************

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
    at IMAGE_OPTIONAL_HEADER32.MajorLinkerVersion,        db 3 ; required for signature :(
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 5 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,   dd Exports_Directory - IMAGEBASE
                                                dd EXPORTS_SIZE ; required for imports forwarding
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceVA,  dd Directory_Entry_Resource - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Exception, dd Exception - IMAGEBASE, EXCEPTION_SIZE
    at IMAGE_DATA_DIRECTORY_16.Security,    dd security - IMAGEBASE - (SECTIONALIGN - FILEALIGN)
                                                dd SECURITY_LENGTH
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE
    at IMAGE_DATA_DIRECTORY_16.Description, dd copyright_string - IMAGEBASE
                                                dd COPYRIGHT_SIZE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,       dd Image_Tls_Directory32 - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Load,        dd LoadConfig - IMAGEBASE
                                                dd 40h ; fixed XP value?
    at IMAGE_DATA_DIRECTORY_16.IATVA,       dd ImportAddressTable - IMAGEBASE
                                                dd IAT_SIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 4 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 16 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

;*******************************************************************************

MYGROUPID equ 314h
MYICONID equ 628h
MYSTRID equ (uID / 16) + 1
uID equ 150

Directory_Entry_Resource:   ; root directory, type level
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw ENTRIES_COUNT
iend
directory_entries:
    _resourceDirectoryEntry RT_ICON,           resource_icon_ID
    _resourceDirectoryEntry RT_STRING,       resource_string_ID ; only works in 2nd position ?
    _resourceDirectoryEntry RT_GROUP_ICON,    resource_group_ID
    _resourceDirectoryEntry RT_VERSION,     resource_version_ID
    _resourceDirectoryEntry RT_MANIFEST,   resource_manifest_ID
ENTRIES_COUNT equ ($ - directory_entries) / IMAGE_RESOURCE_DIRECTORY_ENTRY_size

resource_icon_ID     _resource_tree  MYICONID,     icon_data,     ICON_SIZE
resource_group_ID    _resource_tree MYGROUPID,    group_data,    GROUP_SIZE
resource_version_ID  _resource_tree         1,  version_data,  VERSION_SIZE
resource_manifest_ID _resource_tree     MYMAN, manifest_data, MANIFEST_SIZE
resource_string_ID   _resource_tree   MYSTRID,   string_data,   STRING_SIZE

_d
;***********************

icon_data:
    incbin 'icon.bin' ; header-less ICON data
ICON_SIZE equ $ - icon_data

_d
;***********************

group_data:
istruc GRPICONDIR
    at GRPICONDIR.idType, dw 1
    at GRPICONDIR.idCount, dw GRPDIRCOUNT
iend
GRPDIR:
istruc GRPICONDIRENTRY
    ; theoretically filled with Width, Height...
    at GRPICONDIRENTRY.dwBytesInRes , dd ICON_SIZE
    at GRPICONDIRENTRY.nId          , dw MYICONID
iend
GRPDIRCOUNT equ ($ - GRPDIR ) / GRPICONDIRENTRY_size

GROUP_SIZE equ $ - group_data

_d
;***********************

version_data:
VS_VERSION_INFO:
    .wLength dw VERSIONLENGTH
    .wValueLength dw VALUELENGTH
    .wType dw 0 ; 0 = bin, 1 = text
    WIDE 'VS_VERSION_INFO'
        align 4, db 0
    Value:
        istruc VS_FIXEDFILEINFO
            at VS_FIXEDFILEINFO.dwSignature, dd 0FEEF04BDh
            at VS_FIXEDFILEINFO.dwFileVersionMS, dd (128 << 16) | 0
            at VS_FIXEDFILEINFO.dwFileVersionLS, dd   (0 << 16) | 1
        iend
    VALUELENGTH equ $ - Value
        align 4, db 0
    ; children
    StringFileInfo:
        dw STRINGFILEINFOLEN
        dw 0 ; no value
        dw 0 ; type
        WIDE 'StringFileInfo'
            align 4, db 0
        ; children
        StringTable:
            dw STRINGTABLELEN
            dw 0 ; no value
            dw 0
            WIDE '00000000' ; language value as ascii, required for XP
                align 4, db 0
            ;children
                __string 'FileDescription', 'a "standard" PE' ; required or won't be displayed by explorer
                __string 'FileVersion', 'required for Tab display under XP'
                __string 'LegalCopyright', 'corkami.com'
                STRINGTABLELEN equ $ - StringTable
    STRINGFILEINFOLEN equ $ - StringFileInfo

    VarFileInfo:
        dw VARFILEINFOLENGTH
        dw 0 ; no value
        dw 0 ; type
        WIDE 'VarFileInfo'
            align 4, db 0
        ; children
        Var1:
            dw VAR1LEN
            dw VAR1VALLEN
            dw 0
            WIDE 'Translation'
                align 4, db 0
            Var1Val:
                dd 00000h << 16 + 000h ; language value as binary, required for XP
            VAR1VALLEN equ $ - Var1Val
                align 4, db 0
        VAR1LEN equ $ - Var1
    VARFILEINFOLENGTH equ $ - VarFileInfo
VERSIONLENGTH equ $ - VS_VERSION_INFO

VERSION_SIZE equ $ - version_data

_d
;***********************

MYMAN equ CREATEPROCESS_MANIFEST_RESOURCE_ID
LANGUAGE equ 0

manifest_data:
db "<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'/>"
MANIFEST_SIZE equ $ - manifest_data

myactctx:
istruc ACTCTX
    at ACTCTX.cbSize,         dd ACTCTX_size
    at ACTCTX.dwFlags,        dw ACTCTX_FLAG_HMODULE_VALID \
                                + ACTCTX_FLAG_APPLICATION_NAME_VALID \
                                + ACTCTX_FLAG_RESOURCE_NAME_VALID
    at ACTCTX.lpSource,       dd thisEXE ; required for XP
    at ACTCTX.lpResourceName, dd MYMAN
    at ACTCTX.hModule,        dd IMAGEBASE
iend

_d
;***********************
string_data:
    times (uID % 16) dw 0 ; a null string is the same as no string

dw STRLEN
stringresource db ' - RT_STRING resource loaded', 0ah, 0
    STRLEN equ ($ - stringresource)

STRING_SIZE equ $ - string_data

_d
;*******************************************************************************

tls_callback:
    push tlsmsg
    call [__imp__printf]
    add esp, 1 * 4
_
    push tls_callback2
    pop dword [CallBacks + 4]
    retn

tls_callback2:
    mov word [EntryPoint + 5], 025ffh
    int3

EntryPoint:
reloc01:
    call error_
    int3
    nop
        dd __imp__export
    int3

Export1:
    push exportMSG
    call [__imp__printf]
    add esp, 1 * 4
_
    push MYGROUPID
    push IMAGEBASE
    call [__imp__LoadIconA]

    test eax, eax
    jz error_

    push iconMSG
    call [__imp__printf]
    add esp, 1 * 4
_
    push myactctx
    call [__imp__CreateActCtx]

    cmp eax, -1
    jz error_

    push manifestMSG
    call [__imp__printf]
    add esp, 1 * 4
_
    push STRLEN
    push stringMSG
    push uID
    push 0
    call [__imp__LoadStringA]
    test eax, eax
    jz error_

    push stringMSG
    call [__imp__printf]
    add esp, 1 * 4
_
    push Handler
    push dword [fs:0]
    mov [fs:0], esp

    int3        ; trigger an exception

error_:
    push errorMsg
    call [__imp__printf]
    add esp, 1 * 4

end_:
    push 0
    call [__imp__ExitProcess]
_c
EndCode:

Handler:
    push safesehmsg
    call [__imp__printf]
    add esp, 1 * 4
    jmp end_
_c

tlsmsg db " - Thread Local Storage callback executed", 0dh, 0ah, 0
exportMSG db " - Export called", 0dh, 0ah, 0
iconMSG db " - RT_ICON resource loaded", 0dh, 0ah, 0
safesehmsg db " - exception handler called", 0dh, 0ah, 0
manifestMSG db " - RT_MANIFEST resource located", 0dh, 0ah, 0
errorMsg db "*ERROR*", 0dh, 0ah, 0
stringMSG times STRLEN db 0
_d

;*******************************************************************************

Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd kernel32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd msvcrt.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd user32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd user32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd user32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd own_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd thisEXE - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd own_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames
    dd hnExitProcess - IMAGEBASE
    dd hnCreateActCtx - IMAGEBASE
    dd 0

user32.dll_hintnames   dd hnLoadIconA   - IMAGEBASE, hnLoadStringA - IMAGEBASE, 0
msvcrt.dll_hintnames   dd hnprintf - IMAGEBASE, 0
own_hintnames          dd hnexport - IMAGEBASE
    dd 0
_d

hnExitProcess db 0,0, 'ExitProcess', 0
hnLoadIconA   db 0,0, 'LoadIconA', 0
hnLoadStringA db 0,0, 'LoadStringW', 0

hnprintf      db 0,0, 'printf', 0
hnexport      db 0,0, 'export', 0
hnCreateActCtx:
    dw 0
    db 'CreateActCtxA', 0
_d

ImportAddressTable:

kernel32.dll_iat:
__imp__ExitProcess dd hnExitProcess - IMAGEBASE
__imp__CreateActCtx:
    dd hnCreateActCtx - IMAGEBASE
    dd 0

user32.dll_iat:
__imp__LoadIconA   dd hnLoadIconA - IMAGEBASE
__imp__LoadStringA dd hnLoadStringA  - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf      dd hnprintf - IMAGEBASE
    dd 0

own_iat:
__imp__export      dd hnexport - IMAGEBASE
    dd 0
_d


IAT_SIZE equ $ - ImportAddressTable

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll   db 'msvcrt.dll', 0
user32.dll   db 'user32.dll', 0
thisEXE      db 'standard.exe', 0

_d

;*******************************************************************************
copyright_string:
    db 'Ange Albertini 2013', 0
COPYRIGHT_SIZE equ $ - copyright_string
_d

;*******************************************************************************

Exports_Directory:
istruc IMAGE_EXPORT_DIRECTORY
  at IMAGE_EXPORT_DIRECTORY.NumberOfFunctions,     dd NUMBER_OF_FUNCTIONS
  at IMAGE_EXPORT_DIRECTORY.NumberOfNames,         dd NUMBER_OF_NAMES
  at IMAGE_EXPORT_DIRECTORY.AddressOfFunctions,    dd address_of_functions - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNames,        dd address_of_names - IMAGEBASE
  at IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals, dd address_of_name_ordinals - IMAGEBASE
_d

address_of_functions:
    dd adllfwloop_loophere  - IMAGEBASE
    dd adllfwloop_looponceagain  - IMAGEBASE
    dd amsvcrt_printf - IMAGEBASE
    dd adllfwloop_GroundHogDay - IMAGEBASE
    dd adllfwloop_Yang - IMAGEBASE
    dd adllfwloop_Ying - IMAGEBASE
    dd Export1 - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd a__exp__ExitProcess - IMAGEBASE
    dd a__exp__LoopHere - IMAGEBASE
    dd a__exp__LoopOnceAgain - IMAGEBASE
    dd a__exp__GroundHogDay - IMAGEBASE
    dd a__exp__Ying - IMAGEBASE
    dd a__exp__Yang - IMAGEBASE
    dd hnexport + 2 - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4
_d

adllfwloop_loophere db 'standard.LoopHere', 0
adllfwloop_looponceagain db 'standard.LoopOnceAgain', 0
amsvcrt_printf db "msvcrt.printf", 0
adllfwloop_GroundHogDay db 'standard.GroundHogDay', 0
adllfwloop_Ying db 'standard.Ying', 0
adllfwloop_Yang db 'standard.Yang', 0

_d

address_of_name_ordinals:
    dw 0, 1, 2, 3, 4, 5, 6
_d

a__exp__ExitProcess db 'ExitProcess', 0
a__exp__LoopHere db 'LoopHere', 0
a__exp__LoopOnceAgain db 'LoopOnceAgain', 0
a__exp__GroundHogDay db 'GroundHogDay', 0
a__exp__Ying db 'Ying', 0
a__exp__Yang db 'Yang', 0
_d

EXPORTS_SIZE equ $ - Exports_Directory

Image_Tls_Directory32: ;********************************************************
istruc IMAGE_TLS_DIRECTORY32
    at IMAGE_TLS_DIRECTORY32.AddressOfIndex,     dd EntryPoint + 1
    at IMAGE_TLS_DIRECTORY32.AddressOfCallBacks, dd CallBacks
iend
_d

CallBacks:
    dd tls_callback
    dd 0
    dd 0
_d

LoadConfig: ;*******************************************************************

istruc IMAGE_LOAD_CONFIG_DIRECTORY32
    at IMAGE_LOAD_CONFIG_DIRECTORY32.Size,           dd IMAGE_LOAD_CONFIG_DIRECTORY32_size
    at IMAGE_LOAD_CONFIG_DIRECTORY32.SecurityCookie, dd cookie
    at IMAGE_LOAD_CONFIG_DIRECTORY32.SEHandlerTable, dd HandlerTable
    at IMAGE_LOAD_CONFIG_DIRECTORY32.SEHandlerCount, dd HANDLERCOUNT
iend

LOADCONFIGSIZE equ $ - LoadConfig

cookie dd 0

HandlerTable:
    dd Handler - IMAGEBASE ; add this to get the handler accepted
    HANDLERCOUNT equ ($ - HandlerTable) / 4
    dd 0

_d

;*******************************************************************************
Exception:
istruc RUNTIME_FUNCTION
    at RUNTIME_FUNCTION.FunctionStart, dd EntryPoint - IMAGEBASE
    at RUNTIME_FUNCTION.FunctionEnd,   dd EndCode - IMAGEBASE
    at RUNTIME_FUNCTION.UnwindInfo,    dd UnwindData - IMAGEBASE
iend
EXCEPTION_SIZE equ $ - Exception

UnwindData:
istruc UNWIND_INFO
    at UNWIND_INFO.Ver3_Flags     , db 1 + (UNW_FLAG_EHANDLER << 3)
    at UNWIND_INFO.CntUnwindCodes , db 0 ; let's shrink it to the minimum
iend
align 4, db 0
    dd Handler - IMAGEBASE ; 1 exception handler
    dd 0                   ; handler data
_d
;*******************************************************************************
Directory_Entry_Basereloc:
block_start0:
istruc IMAGE_BASE_RELOCATION
    at IMAGE_BASE_RELOCATION.VirtualAddress, dd reloc01 - IMAGEBASE
    at IMAGE_BASE_RELOCATION.SizeOfBlock,    dd BASE_RELOC_SIZE_OF_BLOCK0
iend
    dw (IMAGE_REL_BASED_ABSOLUTE << 12) | (reloc01 + 1 - reloc01)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc
;*******************************************************************************

align FILEALIGN, db 0 ; end of virtual file here

;*******************************************************************************
security:
istruc WIN_CERTIFICATE
    at WIN_CERTIFICATE.dwLength,         dd SECURITY_LENGTH
    at WIN_CERTIFICATE.wRevision,        dw 200h
    at WIN_CERTIFICATE.wCertificateType, dw 2
iend
;    at WIN_CERTIFICATE.bCertificate
    incbin 'signature.bin'

SECURITY_LENGTH equ $ - security
