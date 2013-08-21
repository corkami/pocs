; a PE to be executed via TLS callback

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

%include 'code_printf.inc'

Msg db " * executed via imported TLS", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0
