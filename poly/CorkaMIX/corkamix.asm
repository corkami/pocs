; a binary that is a valid JAR, PE, ZIP, HTML
; mixed version

;Ange Albertini, BSD Licence, 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE

; PE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db 'MZ'

; python;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db '=1;print("CorkaMIX [python]")'
db 26 ; EOF

; PDF start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db '%PDF-1.', 0ah
db 'obj<<>>stream', 0ah

; HTML start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db '<html>'

; PE resumes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

e_lfanew dd NT_Signature - IMAGEBASE

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
msg  db 'CorkaMIX [PE]', 0
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd 4
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd 4
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
db "<body>"
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFIMAGE - 1
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 db IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 13
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE
iend

bits 32
EntryPoint:
    db 0fh, 018h, 111b << 3
    push msg
    call [__imp__printf]
    salc
    add esp, 1 * 4
    retn

Import_Descriptor: ; slightly messed up
        ImportsAddressTable:
                msvcrt.dll_iat:
                __imp__printf:
                    dd hnprintf - IMAGEBASE
                    dd 0
        IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable
    dd 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
        msvcrt.dll  db 'msvcrt'
hnprintf:
    dw 0
    db 'printf', 0
                times 5 db 0
SIZEOFIMAGE equ $ - IMAGEBASE

; HTML ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db "<style>body { visibility:hidden;} .n { visibility: visible; position: absolute; padding: 0 1ex 0 1ex; margin: 0; top: 0; left: 0; } h1 { margin-top: 0.4ex; margin-bottom: 0.8ex; }</style><div class=n>" 
db " <script type='text/javascript'>alert('CorkaMIX [HTML+JavaScript]');</script><!--"

; ZIP start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;unneeded for Java
CRC32class equ 0
CRC32manifest equ 0

header:
    db 'PK', 3, 4
    dw 0ah ; version_needed
	dw 0 ; flags
	dw 0 ; compression
	dd 0 ; LASTMOD
    dd 0 ; crc32
    dd 0 ; compressed size
    dd 0 ; uncompressed size
    dw DIRLEN
    dw 0 ; extra_length
    dir:
        db 'META-INF/'
    DIRLEN equ $ - dir

file1:
    db 'PK', 3, 4
    dw 0ah ; version_needed
	dw 0 ; flags
	dw 0 ; compression
	dd 0 ; LASTMOD
    dd CRC32manifest ; crc32
    dd FILESIZE1 ; compressed size
    dd FILESIZE1 ; uncompressed size
    dw FILENAMELEN1
    dw 0 ; extra_length
	filename1:
		db 'META-INF/MANIFEST.MF'
	FILENAMELEN1 equ $ - filename1

    data1:
		db 'Created-By: 1', 0ah
		db 'Main-Class: corkamix', 0ah
    FILESIZE1 equ $ - data1

file2:
    db 'PK', 3, 4
    dw 0ah ; version_needed
	dw 0 ; flags
	dw 0 ; compression
	dd 0 ; LASTMOD
    dd CRC32class ; crc32
    dd FILESIZE2 ; compressed size
    dd FILESIZE2 ; uncompressed size
    dw FILENAMELEN2
    dw 0 ; extra_length
	filename2:
		db 'corkamix.class'
	FILENAMELEN2 equ $ - filename2

    data2:

; CLASS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include 'java.inc'

_dd 0CAFEBABEh ; signature
_dw 3          ; major version
_dw 2dh        ; minor version

_dw 23         ;constant pool count
; this class
  classref 2                           ; 01
      utf8 'corkamix'                  ; 02
; super class
  classref 4                           ; 03
      utf8 'java/lang/Object'          ; 04
; method name
  utf8 'main'                          ; 05
; method type
  utf8 '([Ljava/lang/String;)V'        ; 06
; attribute name
  utf8 'Code'                          ; 07

; getstatic
  fieldref 9, 11                       ; 08
      classref 10                      ; 09
          utf8 'java/lang/System'      ; 10
      nat 12, 13                       ; 11
          utf8 'out'                   ; 12
          utf8 'Ljava/io/PrintStream;' ; 13

; LDC
  string 15                            ; 14
   utf8 'CorkaMIX [Java CLASS in JAR]' ; 15

; InvokeVirtual
  metref 17, 19                        ; 16
      classref 18                      ; 17
          utf8 'java/io/PrintStream'   ; 18
      nat 20, 21                       ; 19
          utf8 'println'               ; 20
          utf8 '(Ljava/lang/String;)V' ; 21

; PDF end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ut8 containing the PDF's end
db 1 ;
_dw pdfend - 1 -$
        db 'endstream', 0ah
        db 'endobj', 0ah
        db '1 0 obj<</Kids[<</Parent 1 0 R/Contents[2 0 R]>>]/Resources<<>>>>2 0 obj<<>>stream', 0ah
        db 'BT/default 80 Tf 1 0 0 1 1 715 Tm(CorkaMIX [PDF])Tj ET', 0ah
        db 'endstream', 0ah
        db 'endobj', 0ah
        db 'trailer<</Root<</Pages 1 0 R>>>>', 0ah
pdfend: 

; CLASS resumes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_dw 1  ;access_flag: public

_dw 1 ;this class
_dw 3 ;super class

_dw 0 ; interfaces_count

_dw 0 ; fields_count

_dw 1 ; methods_count
    _dw 9  ; flags: public, static
    _dw 5  ; methodname: 'main'
    _dw 6  ; return type: ([Ljava/lang/String;)V
    _dw 1  ; attribute_count
        _dw 7   ; attributename: Code
        _dd 15h ; length
            _dw 2 ; maxlocals
            _dw 1 ; maxstack
            _dd 9 ; length of bytecode
                GETSTATIC 8
                LDC 14
                INVOKEVIRTUAL 16
                RETURN
            _dw 0 ; exceptions_count
            _dw 0 ; attributes_count

_dw 0 ;attributes_count

; CLASS ends ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    FILESIZE2 equ $ - data2

central_directory:
    db 'PK', 1, 2
    dw 014h ; version_made_by
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; last_mod time/date
    dd 0 ; crc32
    dd 0 ; compressed_size
    dd 0 ; uncompressed_size
    dw DIRLEN
    dw 0 ; extra_length
    dw 0 ; comment_length
    dw 0 ; disk_number_start
    dw 0   ; internal_attr
    dd 10h ; external_attr
    dd 0   ; offset_header
		db 'META-INF/'

    db 'PK', 1, 2
    dw 014h ; version_made_by
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; last_mod time/date
    dd CRC32manifest ; crc32
    dd FILESIZE1 ; compressed_size
    dd FILESIZE1 ; uncompressed_size
    dw FILENAMELEN1
    dw 0 ; extra_length
    dw 0 ; comment_length
    dw 0 ; disk_number_start
    dw 0   ; internal_attr
    dd 20h ; external_attr
    dd file1 - header  ; offset_header
		db 'META-INF/MANIFEST.MF'

    db 'PK', 1, 2
    dw 014h ; version_made_by
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; last_mod time/date
    dd CRC32class ; crc32
    dd FILESIZE2 ; compressed_size
    dd FILESIZE2 ; uncompressed_size
    dw FILENAMELEN2
    dw 0 ; extra_length
    dw 0 ; comment_length
    dw 0 ; disk_number_start
    dw 0   ; internal_attr
    dd 20h ; external_attr
    dd file2 - header ; offset_header
		db 'corkamix.class'

end_central_directory:
    db 'PK', 5, 6
    number_disk dw 0
    number_disk2 dw 0
    total_number_disk dw 3
    total_number_disk2 dw 3
    dd end_central_directory - central_directory;size
    dd central_directory - header ;offset
    dw 0 ; comment_length

; trick to prevent python to handle the file as a zip
; dd 0 ; will screw up the java loading
