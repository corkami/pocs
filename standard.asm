; a PE with many standard characteristics, as a standard 'have everything' PE

; Ange Albertini, BSD LICENCE 2013

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
    at IMAGE_OPTIONAL_HEADER32.MajorLinkerVersion,        db 3 ; required for signature
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
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE

    at IMAGE_DATA_DIRECTORY_16.ResourceVA,  dd Directory_Entry_Resource - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Security,    dd security - IMAGEBASE - (SECTIONALIGN - FILEALIGN), SECURITY_LENGTH
    at IMAGE_DATA_DIRECTORY_16.TLSVA,       dd Image_Tls_Directory32 - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Load,        dd LoadConfig - IMAGEBASE, 40h ; fixed XP value?
    at IMAGE_DATA_DIRECTORY_16.IATVA,       dd ImportAddressTable - IMAGEBASE, IAT_SIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 4 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 15 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

;******************************************************************************

MYGROUPID equ 314h
MYICONID equ 628h

Directory_Entry_Resource:   ; root directory, type level
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 4
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd RT_ICON
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_icon_ID - Directory_Entry_Resource)
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd RT_GROUP_ICON
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_group_ID - Directory_Entry_Resource)
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd RT_VERSION
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_version_ID - Directory_Entry_Resource)
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd RT_MANIFEST
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (manifest_directory_type - Directory_Entry_Resource)
iend

resource_icon_ID:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd MYICONID
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_icon_language - Directory_Entry_Resource)
iend

resource_icon_language:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    ; language doesn't matter
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd icon_entry - Directory_Entry_Resource
iend

icon_entry:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd icon_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd ICON_SIZE
iend


resource_group_ID:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd MYGROUPID
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_group_language - Directory_Entry_Resource)
iend

resource_group_language:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    ; language doesn't matter
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd group_entry - Directory_Entry_Resource
iend

group_entry:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd group_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd GROUP_SIZE
iend


resource_version_ID:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd 1 ; name of the underneath resource
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_version_language - Directory_Entry_Resource)
iend

resource_version_language:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd resource_version_entry - Directory_Entry_Resource
iend

resource_version_entry:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd resource_version_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd VERSION_SIZE
iend


manifest_directory_type:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd MYMAN
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (manifest_directory_language - Directory_Entry_Resource)
iend

manifest_directory_language:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd LANGUAGE ; name of the underneath resource
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd manifest_entry - Directory_Entry_Resource
iend

manifest_entry:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd manifest_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd MANIFEST_SIZE
iend

;******************************************************************************

icon_data:
    incbin 'icon.bin' ; header-less ICON data
ICON_SIZE equ $ - icon_data


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

;*******************************************************************************

resource_version_data:
VS_VERSION_INFO:
    .wLength dw VERSIONLENGTH
    .wValueLength dw VALUELENGTH
    .wType dw 0 ; 0 = bin, 1 = text
    WIDE 'VS_VERSION_INFO'
        align 4, db 0
    Value:
        istruc VS_FIXEDFILEINFO
            at VS_FIXEDFILEINFO.dwSignature, dd 0FEEF04BDh
            at VS_FIXEDFILEINFO.dwFileVersionMS, dd (1 << 16) | 2
            at VS_FIXEDFILEINFO.dwFileVersionLS, dd (3 << 16) | 4
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
            WIDE '040904b0' ; required correct
                align 4, db 0
            ;children
                ; required or won't be displayed by explorer
                __string 'FileDescription', 'a "standard" PE'
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
                dd 04b00h << 16 + 409h
            VAR1VALLEN equ $ - Var1Val
                align 4, db 0
        VAR1LEN equ $ - Var1
    VARFILEINFOLENGTH equ $ - VarFileInfo
VERSIONLENGTH equ $ - VS_VERSION_INFO

VERSION_SIZE equ $ - Directory_Entry_Resource

;*******************************************************************************

MYMAN equ CREATEPROCESS_MANIFEST_RESOURCE_ID
LANGUAGE equ 0

manifest_data:
db "<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'/>"
MANIFEST_SIZE equ $ - manifest_data

myactctx:
istruc ACTCTX
    at ACTCTX.cbSize, dd ACTCTX_size
    at ACTCTX.dwFlags, dw ACTCTX_FLAG_HMODULE_VALID + ACTCTX_FLAG_APPLICATION_NAME_VALID + ACTCTX_FLAG_RESOURCE_NAME_VALID
    at ACTCTX.lpSource, dd thisEXE ; required for XP
    at ACTCTX.lpResourceName, dd MYMAN
    at ACTCTX.hModule, dd IMAGEBASE
iend

;******************************************************************************

tls:
    push tlsmsg
    call [__imp__printf]
    add esp, 1 * 4
    retn

Handler:
    push safesehmsg
    call [__imp__printf]
    add esp, 1 * 4
    jmp end_

Export1:
    push exportMSG
    call [__imp__printf]
    add esp, 1 * 4

    push MYGROUPID
    push IMAGEBASE
    call [__imp__LoadIconA]

    test eax, eax
    jz end_

    push iconMSG
    call [__imp__printf]
    add esp, 1 * 4

    push myactctx
    call [__imp__CreateActCtx]

    cmp eax, -1
    jz end_

    push manifestMSG
    call [__imp__printf]
    add esp, 1 * 4

    push Handler ; set an exception handler
    push dword [fs:0]
    mov [fs:0], esp

    int3        ; trigger an exception

end_:
    push 0
    call [__imp__ExitProcess]
_c

EntryPoint:
    jmp [__imp__export]
    retn

iconMSG db " - icon loaded", 0dh, 0ah, 0
exportMSG db " - Export called", 0dh, 0ah, 0
tlsmsg db " - Thread Local Storage callback executed", 0dh, 0ah, 0
safesehmsg db " - exception handler called", 0dh, 0ah, 0
manifestMSG db " - Manifest located", 0dh, 0ah, 0

_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

user32.dll_hintnames   dd hnLoadIconA   - IMAGEBASE, 0
msvcrt.dll_hintnames   dd hnprintf - IMAGEBASE, 0
own_hintnames          dd hnexport - IMAGEBASE
    dd 0
_d

hnExitProcess db 0,0, 'ExitProcess', 0
hnLoadIconA   db 0,0, 'LoadIconA', 0
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

;******************************************************************************

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd 0
  Base                  dd 0
  NumberOfFunctions     dd 3
  NumberOfNames         dd 1
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_ordinals - IMAGEBASE
_d

address_of_functions:
    dd Export1 - IMAGEBASE
_d

address_of_names:
 dd hnexport + 2 - IMAGEBASE


address_of_ordinals dw 0


align 4, db 0

Image_Tls_Directory32: ;********************************************************
    .StartAddressOfRawData dd 0
    .EndAddressOfRawData   dd 0
    .AddressOfIndex        dd TlsIndex
    .AddressOfCallBacks    dd CallBacks
    .SizeOfZeroFill        dd 0
    .Characteristics       dd 0
_d

TlsIndex dd -1

CallBacks:
    dd tls
    dd 0
_d_d

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

;*******************************************************************************

align FILEALIGN, db 0 ; end of virtual file here

;*******************************************************************************
security:
.dwLength dd SECURITY_LENGTH
.wRevision dw 200h
.wCertificateType dw 2
;.bCertificate
incbin 'signature.bin'

SECURITY_LENGTH equ $ - security
