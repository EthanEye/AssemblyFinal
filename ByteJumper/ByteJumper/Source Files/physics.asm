INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
EXTERN ChangeCharAt@0 : PROC

.data
isGrounded BYTE 1
xCoord DWORD ?
yCoord DWORD ?
newChar WORD ?
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
call ChangeCharAt@0



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