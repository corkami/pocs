; a PE with a resource, loaded by name

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

SOME_TYPE equ 315h

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceVA, dd Directory_Entry_Resource - IMAGEBASE
iend

%include 'section_1fa.inc'

EntryPoint:
    push arestype               ; lpType
    push aresname               ; lpName
    push 0                      ; hModule
    call [__imp__FindResourceA]
_
    push eax
    push 0                      ; hModule
    call [__imp__LoadResource]
_
    push eax
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

aresname db 'RES', 0
arestype db 'TYPE', 0
_d

Import_Descriptor: ;************************************************************
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd hnFindResourceA - IMAGEBASE
    dd hnLoadResource - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnFindResourceA:
    dw 0
    db 'FindResourceA', 0
hnLoadResource:
    dw 0
    db 'LoadResource', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
__imp__FindResourceA:
    dd hnFindResourceA - IMAGEBASE
__imp__LoadResource:
    dd hnLoadResource  - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d
_d

;*******************************************************************************
resource_directory:

Directory_Entry_Resource:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfNamedEntries, dw 1
iend
_resourceDirectoryEntry (1 << 31) | (alrestype - resource_directory), resource_directory_type_rcdata


; type subdirectory
resource_directory_type_rcdata:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfNamedEntries, dw 1
iend
_resourceDirectoryEntry (1 << 31) | (alresname - resource_directory), resource_directory_languages0


; resource subdirectory
resource_directory_languages0:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
IMAGE_RESOURCE_DIRECTORY_ENTRY_001:
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_ENTRY_101 - resource_directory
iend


IMAGE_RESOURCE_DATA_ENTRY_101:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd resource_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd RESOURCE_SIZE
iend


align 4, db 0

; length + widestring
alresname dw 3, "R", "E", "S", 0
alrestype dw 4, "T", "Y", "P", "E", 0

resource_data:
Msg db " * resource loaded by 'named' name and type", 0ah, 0
RESOURCE_SIZE equ $ - resource_data
_d

align FILEALIGN, db 0
