; a PE with appended data

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * appended data", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0
db "appended data... length doesn't matter, it won't be loaded in memory, it's outside the physical space (physical size and sizeofheaders) of the file)"