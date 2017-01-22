; Ange Albertini, BSD Licence 2014 - 2017

WIDTH  equ 3
HEIGHT equ 1

; *****************************************************************************

TRAILER equ 0x3b

struc header
	.signature resb 3
	.version   resb 3
endstruc

struc lsd ; local screen descriptor
	.width  resw 1
	.height resw 1
	.flags  resb 1 ; Global Color Table Flag 1b MSB
	            ; Color Resolution        3b
	            ; Sort Flag               1b
	            ; Global Color Table size 3b LSB
	.bgcol  resb 1
	.ratio  resb 1
endstruc

struc id ; image descriptor
	.separator resb 1
	.left      resw 1
	.top       resw 1
	.width     resw 1
	.height    resw 1
	.flags     resb 1 ; Local Color Table Flag 1b MSB
	               ; Interlace Flag         1b
	               ; Sort Flag              1b
	               ; Reserved               2b
	               ; Local Color Table size 3b LSB
endstruc

; *****************************************************************************

istruc header
	at header.signature, db 'GIF'
	at header.version  , db '89a'	
iend

istruc lsd
	at lsd.width , dw WIDTH
	at lsd.height, dw HEIGHT
	at lsd.flags , db 01_010_0_001b ; global color table present, resolution of 3 bits, palette of 4 colors
	;t lsd.bgcol , db 0            ; ignored if there is a global color table
	;t lsd.ratio , db 0            ; no aspect ratio specified
iend

;Global color table
	db 0xff, 0x00, 0x00 ; Red
	db 0x00, 0xff, 0x00 ; Green
	db 0x00, 0x00, 0xff ; Blue
	db 0xff, 0xff, 0xff ; Black

istruc id
	at id.separator, db ','
	at id.left,      dw 0, 0          ; NW corner
	at id.width,     dw WIDTH, HEIGHT ; w/h of image
	;t id.flags,     db 0             ; no local color table, not interlaced
iend

;Table Based Image Data
db 2 ; initial number of bits per LZW codes
	db 2                     ; block size
	dw 0101_010_001_000_100b ; end #2 #1 #0 start
	db 0                     ; block terminator

db TRAILER
