; a 'normal' PE32+

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers64.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

%include 'code_printf64.inc'

Msg db " * a standard PE32+ (imports, standard alignments)", 0ah, 0
_d

%include 'imports_printfexitprocess64.inc'

align FILEALIGN, db 0
