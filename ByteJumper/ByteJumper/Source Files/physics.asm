INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
.data
isGrounded BYTE 1

.code
; Player physics
Jump PROC
mov al, isGrounded
cmp isGrounded, 1
jne endJumpProc_
isGrounded_:
mov isGrounded, 0 ; No longer grounded
mov eax , xCoord
mov ebx, yCoord
mov newChar, ' '
call ChangeCharAt



endJumpProc_:
ret
Jump ENDP

MoveLeft PROC

ret
MoveLeft ENDP



MoveRight PROC

ret
MoveRight ENDP
END 