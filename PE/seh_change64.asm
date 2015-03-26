; a 64b PE changing his SEH on the fly

; Ange Albertini, BSD LICENCE 2012-2013

%include 'consts.inc'

%include 'headers64.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Exception, dd Exception - IMAGEBASE, EXCEPTION_SIZE
iend

%include 'section_1fa.inc'

;*******************************************************************************

InitialHandler:
    lea ecx, [InitialMsg]
    call [__imp__printf]
    xor ecx, ecx
    call [__imp__ExitProcess]
_c

InitialMsg db " * initial handler", 0ah, 0
_d

NewHandler:
    lea ecx, [NewMsg]
    call [__imp__printf]
    xor ecx, ecx
    call [__imp__ExitProcess]
_c

NewMsg db " * a 64b PE with an exception handler address modified on the fly", 0ah, 0
_d

EntryPoint:
    sub rsp, 8 * 5
    add dword [HandlerRVA], NewHandler - InitialHandler
    int3
EndCode:

%include 'imports_printfexitprocess64.inc'

Exception: ;********************************************************************
istruc RUNTIME_FUNCTION
    at RUNTIME_FUNCTION.FunctionStart, dd EntryPoint - IMAGEBASE
    at RUNTIME_FUNCTION.FunctionEnd  , dd EndCode - IMAGEBASE
    at RUNTIME_FUNCTION.UnwindInfo   , dd UnwindData - IMAGEBASE
iend
EXCEPTION_SIZE equ $ - Exception

UnwindData:
istruc UNWIND_INFO
    at UNWIND_INFO.Ver3_Flags     , db 1 + (UNW_FLAG_EHANDLER << 3)
iend
align 4, db 0
HandlerRVA:
    dd InitialHandler - IMAGEBASE
    dd 0

align FILEALIGN, db 0
