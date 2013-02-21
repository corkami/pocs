; a tiny .NET PE

; Ange Albertini BSD Licence 2012

%include 'consts.inc'
%include 'dotnet.inc'

SECALIGN equ 1000h
FILEALIGN equ 200h
CODEDELTA equ FILEALIGN - SECALIGN

org 400000h
bits 32

IMAGEBASE
istruc IMAGE_DOS_HEADER
  at IMAGE_DOS_HEADER.e_magic  , dw 'MZ'
  at IMAGE_DOS_HEADER.e_lfanew , dd PE_Header - IMAGEBASE
iend


PE_Header
istruc IMAGE_NT_HEADERS
  at IMAGE_NT_HEADERS.Signature , db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
  at IMAGE_FILE_HEADER.Machine              , dw IMAGE_FILE_MACHINE_I386
  at IMAGE_FILE_HEADER.NumberOfSections     , dw 1
  at IMAGE_FILE_HEADER.SizeOfOptionalHeader , dw 0e0h
  at IMAGE_FILE_HEADER.Characteristics      , dw 102h
iend
istruc IMAGE_OPTIONAL_HEADER32
  at IMAGE_OPTIONAL_HEADER32.Magic                 , dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
  at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint   , dd EntryPoint - CODEDELTA - IMAGEBASE
  at IMAGE_OPTIONAL_HEADER32.ImageBase             , dd IMAGEBASE
  at IMAGE_OPTIONAL_HEADER32.SectionAlignment      , dd SECALIGN
  at IMAGE_OPTIONAL_HEADER32.FileAlignment         , dd FILEALIGN
  at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion , dw 4, 0
  at IMAGE_OPTIONAL_HEADER32.SizeOfImage           , dd 2 * SECALIGN
  at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders         , dd SIZEOFHEADERS
  at IMAGE_OPTIONAL_HEADER32.Subsystem             , dw IMAGE_SUBSYSTEM_WINDOWS_CUI
  at IMAGE_OPTIONAL_HEADER32.SizeOfStackReserve    , dd 100000h
  at IMAGE_OPTIONAL_HEADER32.SizeOfHeapReserve     , dd 100000h
  at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes   , dd 2 ; :D
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Imports - CODEDELTA - IMAGEBASE, 28h
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,  dd Relocs - CODEDELTA - IMAGEBASE, RELOCS_SIZE
    at IMAGE_DATA_DIRECTORY_16.COM,       dd Cor20 - CODEDELTA - IMAGEBASE, COR20SIZE
iend

istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize      , dd SECTIONSIZE
    at IMAGE_SECTION_HEADER.VirtualAddress   , dd SECALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData    , dd SECTIONSIZE
    at IMAGE_SECTION_HEADER.PointerToRawData , dd SectionSart - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics  , dd 40000000h
iend

align FILEALIGN, db 0
SIZEOFHEADERS equ $ - IMAGEBASE

SectionSart:
Cor20:
istruc IMAGE_COR20_HEADER
    at IMAGE_COR20_HEADER.cb                  , dd COR20SIZE
    at IMAGE_COR20_HEADER.MajorRuntimeVersion , dw 2, 5
    at IMAGE_COR20_HEADER.MetaData            , dd Metadata - CODEDELTA - IMAGEBASE, Metadata_end - Metadata
    at IMAGE_COR20_HEADER.Flags               , dd COMIMAGE_FLAGS_ILONLY
    at IMAGE_COR20_HEADER.EntryPointToken     , dd 6000001h
iend
COR20SIZE equ $ - Cor20

Metadata:
istruc MetadataHeader
    at MetadataHeader.Signature, db 'BSJB'
    at MetadataHeader.Major,     dw 1
    at MetadataHeader.Minor,     dw 1
iend

    dd VERSIONLENGTH
Version:
	db 'v2.0.0',0,0
	VERSIONLENGTH equ $ - Version

flags dw 0
NumbersOfStreams dw 4

	dd MetaStream - Metadata, METALEN
	db '#~',0
		align 4, db 0

	dd String_start - Metadata, STRING_SIZE
	db '#Strings',0
        align 4, db 0

	dd US - Metadata, USLEN
	db '#US',0
        align 4, db 0

	dd blob_start - Metadata, blob_end - blob_start
	db '#Blob',0
        align 4, db 0

MetaStream:
istruc TablesHdr
    at TablesHdr.MajorVersion , db 2
    at TablesHdr.Reserved2    , db 1
    at TablesHdr.MaskValid    , dd 1447h, 9
    at TablesHdr.MaskSorted   , dd 3301FA00h, 1600h
iend

istruc Tables
    at Tables.ModuleCount      , dd 1
    at Tables.TypeRefCount     , dd 4
    at Tables.TypeDefCount     , dd 2
    at Tables.MethodCount      , dd 2
    at Tables.MemberRefCount   , dd 4
    at Tables.AssemblyCount    , dd 1
    at Tables.AssemblyRefCount , dd 1
iend

istruc sModule
    at sModule.Name , dw Strings - String_start
iend

istruc TypeRef
    at TypeRef.ResolutionScope , dw 6
    at TypeRef.Name            , dw aObject - String_start
    at TypeRef.Namespace       , dw aSystem - String_start
iend
istruc TypeRef
    at TypeRef.ResolutionScope , dw 6
    at TypeRef.Name            , dw aCompilationrelaxations - String_start
    at TypeRef.Namespace       , dw aSystem_runtime_compile - String_start
iend
istruc TypeRef
    at TypeRef.ResolutionScope , dw 6
    at TypeRef.Name            , dw aRuntimecompatibilityat - String_start
    at TypeRef.Namespace       , dw aSystem_runtime_compile - String_start
iend
istruc TypeRef
    at TypeRef.ResolutionScope , dw 6
    at TypeRef.Name            , dw aConsole - String_start
    at TypeRef.Namespace       , dw aSystem - String_start
iend

istruc TypeDef
    at TypeDef.Name       , dw Strings - String_start
    at TypeDef.FieldList  , dw 1
    at TypeDef.MethodList , dw 1
iend
istruc TypeDef
    at TypeDef.Flags      , dd 100001h
    at TypeDef.Name       , dw Strings - String_start
    at TypeDef.Extends    , dw 5
    at TypeDef.FieldList  , dw 1
    at TypeDef.MethodList , dw 1
iend

istruc Method
    at Method.RVA       , dd Method1 - CODEDELTA - IMAGEBASE
    at Method.Flags     , dw 96h
    at Method.Name      , dw Strings - String_start
    at Method.Signature , dw 0ah
iend
istruc Method
    at Method.RVA       , dd Method2 - CODEDELTA - IMAGEBASE
    at Method.Flags     , dw 1886h
    at Method.Name      , dw a_ctor -  String_start
    at Method.Signature , dw 0eh
iend

istruc MemberRef
    at MemberRef.Class     , dw 11h
    at MemberRef.Name      , dw a_ctor -  String_start
    at MemberRef.Signature , dw 12h
iend
istruc MemberRef
    at MemberRef.Class     , dw 19h
    at MemberRef.Name      , dw a_ctor -  String_start
    at MemberRef.Signature , dw 0eh
iend
istruc MemberRef
    at MemberRef.Class     , dw 21h
    at MemberRef.Name      , dw aWriteline -  String_start
    at MemberRef.Signature , dw 17h
iend
istruc MemberRef
    at MemberRef.Class     , dw 9h
    at MemberRef.Name      , dw a_ctor -  String_start
    at MemberRef.Signature , dw 0eh
iend

istruc Assembly
    at Assembly.HashAlgId , dd 8004h
    at Assembly.Name      , dw aMscorlib - String_start
iend

istruc AssemblyRef
	at AssemblyRef.MajorVersion , dw 2
	at AssemblyRef.Name         , dw aMscorlib - String_start
iend
METALEN equ $ - MetaStream

String_start: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Strings   db 0
aMscorlib db 'mscorlib',0
aSystem   db 'System',0
aObject   db 'Object',0
a_ctor    db '.ctor',0
aSystem_runtime_compile db 'System.Runtime.CompilerServices',0
aCompilationrelaxations db 'CompilationRelaxationsAttribute',0
aRuntimecompatibilityat db 'RuntimeCompatibilityAttribute',0
aConsole      db 'Console',0
aWriteline    db 'WriteLine',0

STRING_SIZE equ $ - String_start

US ; USER STRINGS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dw 2200h
aA_net2_0Pe:
        WIDE " * a tiny .NET PE"
USLEN equ $ - US

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
blob_start db 0, 8
	b_publickeytoken db 0B7h, 7Ah, 5Ch, 56h, 19h, 34h, 0E0h, 89h,
	b_main db 3,0,0, 1
	b_ctor db 3, 20h, 0, 1
	b_mem1 db 4, 20h, 1, 1, 8
	test17 db 4, 0, 1, 1
				db 0Eh,
	test1c db 8, 1, 0, 8, 0,0,0,0,0
	test25 db 1Eh, 1, 0, 1, 0, 54h, 2
		aWrapnonexceptionthrows db 1,'W'
		db 1
blob_end

Metadata_end

Imports: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
istruc IMPORT_IMAGE_DESCRIPTOR
    at IMPORT_IMAGE_DESCRIPTOR.INT,     dd mscoreeINT - CODEDELTA - IMAGEBASE
    at IMPORT_IMAGE_DESCRIPTOR.DllName, dd aMscoree_dll - CODEDELTA - IMAGEBASE
    at IMPORT_IMAGE_DESCRIPTOR.IAT,     dd _CorExeMain - CODEDELTA - IMAGEBASE
iend
istruc IMPORT_IMAGE_DESCRIPTOR ;terminator
iend

mscoreeINT dd hn_CoreExeMain - IMAGEBASE - CODEDELTA
    dd 0

hn_CoreExeMain:
    dw 0
    db '_CorExeMain',0

aMscoree_dll db 'mscoree.dll',0
IMPORTS_SIZE EQU $ - Imports
_CorExeMain dd ""

Relocs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    block_start:
    dd Corejmp + 2; rva
    dd BLOCKSIZE  ; size
        dw (IMAGE_REL_BASED_HIGHLOW << 12) | 0
    BLOCKSIZE equ $ - block_start
RELOCS_SIZE equ $ - Relocs

EntryPoint: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Corejmp:
	jmp [_CorExeMain - CODEDELTA]

; bytecode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Method1:
db 36h ; unknown ? length ?
db NOP_
db LDSTR, 1, 0, 0, 70h ;ldstr " * a .NET 2.0 PE"
db CALL_, 3, 0, 0, 0Ah ;call void [mscorlib]System.Console::WriteLine(string)
db NOP_
db RET_

Method2:
db 1Eh ; unk ?
db LDARG_0
db CALL_, 4, 0, 0, 0Ah ; call instance void [mscorlib]System.Object::.ctor()
db RET_

dw 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

align FILEALIGN, db 0

SECTIONSIZE equ $ - SectionSart

