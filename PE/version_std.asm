; a PE with version 'standard' info

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

EntryPoint equ IMAGEBASE

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ResourceVA,   dd Directory_Entry_Resource - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceSize, dd RESOURCE_SIZE
iend

%include 'section_1fa.inc'

;*******************************************************************************

; REQUIRED to start with the section !
Directory_Entry_Resource:
; root directory
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
    _resourceDirectoryEntry RT_VERSION, resource_directory_type

resource_directory_type:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
    _resourceDirectoryEntry 1, resource_directory_language

resource_directory_language:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd resource_entry - Directory_Entry_Resource
iend

resource_entry:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd resource_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd RESOURCE_SIZE
iend


resource_data:
VS_VERSION_INFO:
	.wLength dw VERSIONLENGTH
	.wValueLength dw VALUELENGTH
	.wType dw 0 ; 0 = bin, 1 = text
	WIDE 'VS_VERSION_INFO'
		align 4, db 0
	Value:
		istruc VS_FIXEDFILEINFO
			at VS_FIXEDFILEINFO.dwSignature, dd 0FEEF04BDh
			times 6 dd 0ffffffffh
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
				__string 'FileDescription', 'a PE with "standard" version info'
				__string 'FileVersion', 'compulsory for version tab'
				__string 'LegalCopyright', 'corkami.com'
				__string 'StringFileInfo', ''
				__string 'Comments', ''
				__string 'CompanyName', ''
				__string 'InternalName', ''
				__string 'LegalTrademarks', ''
				__string 'OriginalFilename', ''
				__string 'PrivateBuild', ''
				__string 'ProductName', ''
				__string 'ProductVersion', ''
				__string 'SpecialBuild', ''
				__string '', ''
				__string ' ', ''
				__string ' ** EAT AT JOE"S **', 'best hamburger in town'
				__string 'FileVersion', 'duplicates are authorized'

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

RESOURCE_SIZE equ $ - resource_data
_d

;*******************************************************************************

align FILEALIGN, db 0
