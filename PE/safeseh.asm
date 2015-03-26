; a PE with SafeSEH (it should crash if the handler is not enabled in the list)

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

%include 'headers.inc'

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.Load,      dd LoadConfig - IMAGEBASE, 40h ; fixed XP value?
iend

%include 'section_1fa.inc'

;*******************************************************************************

Handler:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4

    push 42
    call [__imp__ExitProcess]
_c

EntryPoint:
    push Handler ; set an exception handler
    push dword [fs:0]
    mov [fs:0], esp

    int3        ; trigger an exception
_c

Msg db " * a PE with SafeSEH: Exception handler called", 0ah, 0
_d

LoadConfig: ;*******************************************************************

istruc IMAGE_LOAD_CONFIG_DIRECTORY32
    at IMAGE_LOAD_CONFIG_DIRECTORY32.Size,           dd IMAGE_LOAD_CONFIG_DIRECTORY32_size
    at IMAGE_LOAD_CONFIG_DIRECTORY32.SecurityCookie, dd cookie
    at IMAGE_LOAD_CONFIG_DIRECTORY32.SEHandlerTable, dd HandlerTable
    at IMAGE_LOAD_CONFIG_DIRECTORY32.SEHandlerCount, dd HANDLERCOUNT
iend

LOADCONFIGSIZE equ $ - LoadConfig

cookie dd 0

HandlerTable:
    dd 0deadbeefh ; fake entry to make the table valid
    dd Handler - IMAGEBASE ; removing this will reject our handler
    HANDLERCOUNT equ ($ - HandlerTable) / 4
    dd 0

;*******************************************************************************

%include 'imports_printfexitprocess.inc'

align FILEALIGN, db 0
