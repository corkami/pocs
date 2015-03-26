EntryPoint:
    sub rsp, 8 * 5
    lea ecx, [Msg]
    call [__imp__printf]
    xor ecx, ecx
    call [__imp__ExitProcess]
_c
