INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
EXTERN ChangeCharAt@0 : PROC
EXTERN GetPlayerXy@0 : PROC
EXTERN SetNewChar@0 : PROC
EXTERN SetPlayerPos@0 : PROC
EXTERN CreateThread@24 : PROC
.data
isGrounded BYTE 1
xCoord DWORD ?
yCoord DWORD ?
newChar WORD ?
textMsg BYTE "Test"
; PHYSICS THREAD
threadID DWORD ?
threadHandle DWORD ?
.code

StartPhysicsThread PROC

  
    ; Create the thread
    push 0                  ; lpThreadId (optional)
    push 0                  ; dwCreationFlags (run immediately)
    push 0                  ; lpParameter (none)
    push OFFSET UpdateMovement ; lpStartAddress
    push 0                  ; dwStackSize (default)
    push 0                  ; lpThreadAttributes (default)
    call CreateThread@24
    mov threadHandle, eax   ; store handle if needed
    ret
  StartPhysicsThread ENDP


  UpdateMovement PROC

  movementLoop_:

  mov eax, 1   ; time in milliseconds
  call Delay
  jmp movementLoop_
  ret
  UpdateMovement ENDP

Jump PROC
mov al, isGrounded
cmp isGrounded, 1
jne endJumpProc_
isGrounded_:
mov isGrounded, 0 ; No longer grounded
call GetPlayerXy@0 ; Get players current position
mov xCoord, eax
mov yCoord, ebx
mov eax , xCoord
mov ebx, yCoord
mov edx, ' '
call SetNewChar@0
call ChangeCharAt@0
mov eax , xCoord
mov ebx, yCoord
inc ebx
mov edx, 'O'
call SetNewChar@0
call ChangeCharAt@0
; Jump Mechanics here



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