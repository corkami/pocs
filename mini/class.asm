; a mini Java CLASS in assembly, doing nothing

; Ange Albertini, BSD Licence 2012-2017

;*******************************************************************************
; macros

%macro RETURN 0
        db 0b1h
%endmacro

%macro _dd 1
    db (%1 >> 8 * 3) & 0ffh
    db (%1 >> 8 * 2) & 0ffh
    db (%1 >> 8 * 1) & 0ffh
    db (%1 >> 8 * 0) & 0ffh
%endmacro

%macro _dw 1
    db (%1 >> 8 * 1) & 0ffh
    db (%1 >> 8 * 0) & 0ffh
%endmacro

%macro lbuffer 1
_dw %%end - 1 -$
    db %1
%%end:
%endmacro

%macro utf8 1
    db 1
        lbuffer %1
%endmacro

%macro string 1
    db 8
        _dw %1
%endmacro

%macro classref 1
    db 7
        _dw %1
%endmacro


ACC_PUBLIC equ 1
ACC_STATIC equ 8

;*******************************************************************************
; header

_dd 0CAFEBABEh ; signature
_dw 3          ; major version
_dw 2dh        ; minor version

;*******************************************************************************
; constant pool
_dw 08        ;constant pool count

 ;<always empty>                       ; 00
  classref 2                           ; 01
      utf8 'mini'                      ; 02

  classref 4                           ; 03
      utf8 'java/lang/Object'          ; 04

  utf8 'main'                          ; 05

  utf8 'Code'                          ; 06

  utf8 '([Ljava/lang/String;)V'        ; 07

_dw ACC_PUBLIC  ;access_flag

_dw 1 ;this class
_dw 3 ;super class

_dw 0 ; interfaces_count
; no interfaces

_dw 0 ; fields_count
; no fields

_dw 1 ; methods_count
    _dw ACC_PUBLIC + ACC_STATIC
    _dw 5 ; methodname: 'main'
    _dw 7 ; return type: ([Ljava/lang/String;)V
    _dw 1 ; attribute_count
        _dw 6   ; attributename: Code
        _dd 13  ; length
            _dw 0 ; maxlocals
            _dw 1 ; maxstack
            _dd 1 ; length of bytecode
                RETURN
            _dw 0 ; exceptions_count
            _dw 0 ; attributes_count

_dw 0 ;attributes_count
; no attributes
