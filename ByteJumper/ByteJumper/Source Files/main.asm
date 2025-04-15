
; MASM Template
; <EthanEye>
; 3/6/2025
; Create a template for assembler files.
.386P

option casemap:none

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib

.data
msg db "Hello, world!", 0
.code
main PROC
_main:
    mov edx, OFFSET msg
    call WriteString
    call Crlf
    push 0
    call ExitProcess       ; use Irvine32's wrapped version

main ENDP

END

