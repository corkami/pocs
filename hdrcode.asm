; a PE which header is completely executed (to calculate a fibonacci number via FPU)

; with the help of Peter Ferrie's "Maximum Possible Code Execution" http://pferrie.host22.com/misc/pehdr.htm

;Ange Albertini, BSD Licence, 2012

%include 'consts.inc'

IMAGEBASE equ 40000h ; to make the FILD immediate address correspond to MajorSubsystemVersion

org IMAGEBASE
bits 32

	dw 'MZ'

	mov eax, ebx ; to pass all these [eax] references...

istruc IMAGE_NT_HEADERS
	at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend

istruc IMAGE_FILE_HEADER
	at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
	at IMAGE_FILE_HEADER.NumberOfSections,      dw 0
; dd timestamp
	db 0c0h
	fninit
	nop

; dd symbol offset
	fild dword [_46]

; dd symbol count
	nop
		db 0c8h

; dw size_of_optional_header
	dw 0

;dw characteristics
	xchg edx, eax ; need to end with 2
		db 00h
iend

istruc IMAGE_OPTIONAL_HEADER32
; dw Magic
	dw IMAGE_NT_OPTIONAL_HDR32_MAGIC

; db MajorLinkerVersion
	db 0c0h ; benign trailing byte for 01

; db MinorLinkerVersion
	nop

; dd Sizeofcode
	fldz
	fld1

; dd SizeOfUninitializedData
_loop:
	fxch st1
	fadd st0, st1

; dd SizeOfInitializedData
	fld1
	nop
	db 0b9h ; => mov ecx, *

; dd AddressOfEntryPoint
		dd 0

; dd BaseOfCode
	fsubp st3
	mov cl, 0 ; can't be too high

; dd BaseOfData
	fldz
	nop
	db 0b8h ; => mov ebx, *

; dd ImageBase
		dd IMAGEBASE

; dd SectionAlignment
	dd 4 ; add al, 0/add [eax], al

; dd FileAlignment
	dd 4 ; add al, 0/add [eax], al

; dw MajorOperatingSystemVersion
	fcomip st3

; dw MinorOperatingSystemVersion
	jnz _loop

; dw MajorImageVersion
	fild qword [true_res] ; 6 bytes, sets up MajorSubsystemVersion to 4
	; times 2 nop

; dw MinorImageVersion
	; times 2 nop

; dw MajorSubsystemVersion
	; add al, 0 ; has to be 3 or more

; dw MinorSubsystemVersion
    xor eax, eax

; dd Win32VersionValue
	times 3 nop
	db 0b9h

; dd SizeOfImage
		dd 0ffffh ; artificially big to get SizeOfHeaders accepted

; dd SizeOfHeaders
	mov cx, 0

; dd Checksum
	times 2 nop
	db 066h, 0b9h ; mov cx, *

; dw Subsystem
		dw IMAGE_SUBSYSTEM_WINDOWS_CUI ; 2

; nothing is strictly required from this point...........

; dw DllCharacteristics
	inc ebx ; bit 7 has to be cleared
	nop

; dd SizeOfStackReserve
	fcomip st1
	
	push ss ; need a 'nop' with low encoding and not changing flags
	pop ss

; dd SizeOfStackCommit
	setnz al ; 3 bytes
	inc eax

; dd SizeOfHeapReserve
	push edx
	retn
	dw 0

; dd SizeOfHeapCommit
	_46 dd 46

; dd LoaderFlags
	true_res dq 2971215073

;        times 3 nop
;        db 0b9h
; dd NumberOfRvaAndSizes
;               dd 0
iend

; now offset 124

times 268 - 124 db 00h ; necessary padding for compatibility with W7 64b, 00's are required for XP at some DDs
