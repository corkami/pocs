; a PE with a checked broken MANIFEST resource

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceVA, dd Directory_Entry_Resource - IMAGEBASE
iend

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * a PE with an incorrect manifest type (ignored)", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

;*******************************************************************************

MYMAN equ 3 ; incorrect - this file wouldn't run if it's set to 1 or 2
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
db "<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'>" ; broken end
RESOURCE_SIZE equ $ - resource_data

align FILEALIGN, db 0
