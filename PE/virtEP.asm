; PE with EntryPoint in virtual space

; Ange Albertini, BSD LICENCE 2009-2013

%include 'consts.inc'

%include 'headers.inc'

%include 'dd_imports.inc'

%include 'section_1fa.inc'

; actual EntryPoint starts here...
; there will be a virtual 00 before, so 00C0 will be executed as `add al, al`
EntryPoint equ PhysEntryPoint - 1
; 00
PhysEntryPoint:
    db 0c0h
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * virtual EntryPoint", 0ah, 0
_d

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0
