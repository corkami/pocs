
struc IMAGE_COR20_HEADER
    .cb                      resd 1
    .MajorRuntimeVersion     resw 1
    .MinorRuntimeVersion     resw 1
    .MetaData                resd 2
    .Flags                   resd 1
    .EntryPointToken         resd 1
    .Resources               resd 2
    .StrongNameSignature     resd 2
    .CodeManagerTable        resd 2
    .VTableFixups            resd 2
    .ExportAddressTableJumps resd 2
    .ManagedNativeHeader     resd 2
endstruc

struc MetadataHeader
    .Signature resd 1
    .Major     resw 1
    .Minor     resw 1
    .Reserved  resd 1
endstruc

struc GUID
    .data resd 8
endstruc

struc ROffsetSize
    .RelOffset resd 1
    .Size      resd 1
endstruc

struc sModule
    .Generation resw 1
    .Name       resw 1
    .Mvid       resw 1
    .EncId      resw 1
    .EncBaseID  resw 1
endstruc

struc TypeRef
    .ResolutionScope resw 1
    .Name            resw 1
    .Namespace       resw 1
endstruc

struc TypeDef
    .Flags      resd 1
    .Name       resw 1
    .NameSpace  resw 1
    .Extends    resw 1
    .FieldList  resw 1
    .MethodList resw 1
endstruc

struc Method
    .RVA       resd 1
    .ImplFlags resw 1
    .Flags     resw 1
    .Name      resw 1
    .Signature resw 1
    .ParamList resw 1
endstruc

struc MemberRef
    .Class     resw 1
    .Name      resw 1
    .Signature resw 1
endstruc

struc CustomAttribute
    .Parent      resw 1
    .Type        resw 1
    .Value       resw 1
endstruc

struc Assembly
    .HashAlgId      resd 1
    .MajorVersion   resw 1
    .MinorVersion   resw 1
    .BuildNumber    resw 1
    .RevisionNumber resw 1
    .Flags          resd 1
    .PublicKey      resw 1
    .Name           resw 1
    .Culture        resw 1
endstruc

struc AssemblyRef
	.MajorVersion     resw 1
	.MinorVersion     resw 1
	.BuildNumber      resw 1
	.RevisionNumber   resw 1
	.Flags            resd 1
	.PublicKeyOrToken resw 1
	.Name             resw 1
	.Culture          resw 1
	.HashValue        resw 1
endstruc

struc Tables
    .ModuleCount          resd 1
    .TypeRefCount         resd 1
    .TypeDefCount         resd 1
    .MethodCount          resd 1
    .MemberRefCount       resd 1
    .CustomAttributeCount resd 1
    .AssemblyCount        resd 1
    .AssemblyRefCount     resd 1
endstruc

struc TablesHdr
    .Reserved1       resd 1
    .MajorVersion    resb 1
    .Minor           resb 1
    .HeapOffsetSizes resb 1
    .Reserved2       resb 1
    .MaskValid       resq 1
    .MaskSorted      resq 1
endstruc

; enum ReplacesCorHdrNumericDefines
COR_VERSION_MINOR EQU 0
COMIMAGE_FLAGS_ILONLY EQU 1
NATIVE_TYPE_MAX_CB EQU 1
IMAGE_COR_MIH_METHODRVA EQU 1
COR_VTABLE_32BIT EQU 1
COMIMAGE_FLAGS_32BITREQUIRED EQU 2
COR_VERSION_MAJOR_V2 EQU 2
COR_VERSION_MAJOR EQU 2
IMAGE_COR_MIH_EHRVA EQU 2
COR_VTABLE_64BIT EQU 2
COMIMAGE_FLAGS_IL_LIBRARY EQU 4
COR_VTABLE_FROM_UNMANAGED EQU 4
COMIMAGE_FLAGS_STRONGNAMESIGNED EQU 8
COR_DELETED_NAME_LENGTH EQU 8
COR_VTABLEGAP_NAME_LENGTH EQU 8
IMAGE_COR_MIH_BASICBLOCK EQU 8
COR_VTABLE_CALL_MOST_DERIVED EQU 10h
IMAGE_COR_EATJ_THUNK_SIZE EQU 20h
COR_ILMETHOD_SECT_SMALL_MAX_DATASIZE EQU 0FFh
MAX_CLASS_NAME EQU 400h
MAX_PACKAGE_NAME EQU 400h
COMIMAGE_FLAGS_TRACKDEBUGDATA EQU 10000h

NOP_ equ 0
LDARG_0 equ 2
LDSTR equ 72h
CALL_ equ 28h
RET_ equ 2ah
