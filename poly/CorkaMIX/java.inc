%macro GETSTATIC 1
        db 0b2h
            _dw %1
%endmacro

%macro LDC 1
        db 012h
            db %1
%endmacro

%macro INVOKEVIRTUAL 1
        db 0b6h
            _dw %1
%endmacro

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

%macro nat 2
        db 0ch
        _dw %1
        _dw %2
%endmacro

%macro string 1
        db 8
        _dw %1
%endmacro

%macro classref 1
        db 7
        _dw %1
%endmacro

%macro fieldref 2
        db 9
        _dw %1
        _dw %2
%endmacro

%macro metref 2
        db 0ah
        _dw %1
        _dw %2
%endmacro
