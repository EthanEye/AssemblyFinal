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
direction DWORD 4 dup(?)
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
  
  ; All inputs call this method to update player position
  ; EDX = direction 1- DOWN 2 - UP, 3 LEFT, 4 RIGHT
Movement PROC

   
    call GetPlayerXy@0
    cmp edx, 2
    jne Left_
    Jump_:
    ; 1. Get player position
    call GetPlayerXy@0
    mov xCoord, eax
    mov yCoord, ebx

    ; 2. Clear old position
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0

    ; 3. Move Up
    inc yCoord

    ; 4. Draw new position
    mov ecx, 'O'
    mov eax, xCoord
    mov ebx, yCoord
    call SetNewChar@0
    call ChangeCharAt@0

    ; 5. Save updated position
    mov eax, xCoord
    mov ebx, yCoord
    call SetPlayerPos@0
    call UpdatePlayerBody
   
    Left_:
    cmp edx, 3
    jne Right_
    ; 1. Get player position
    call GetPlayerXy@0
    mov xCoord, eax
    mov yCoord, ebx
    ; 2. Clear old position
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Move left
    dec xCoord
    ; 4. Draw new position
    mov ecx, 'O'
    mov eax, xCoord
    mov ebx, yCoord
    call SetNewChar@0
    call ChangeCharAt@0
    ; 5. Save updated position
    mov eax, xCoord
    mov ebx, yCoord
    call SetPlayerPos@0
    call UpdatePlayerBody
    mov ecx, ' '
    call GetPlayerXy@0
    add eax, 2
    sub ebx, 1
    call SetNewChar@0
    call ChangeCharAt@0
    call GetPlayerXy@0
    add eax, 2
    sub ebx, 2
    call SetNewChar@0
    call ChangeCharAt@0
    cmp edx, 4
    jne endMovementProc_
    Right_:
    

    endMovementProc_:
    mov edx, 0
ret
Movement ENDP

UpdatePlayerBody PROC
 ; 1. Get head position
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    ; -------- Draw torso below head --------
    mov eax, xCoord
    mov ebx, yCoord
    dec ebx                    ; torso = head Y + 1
    mov ecx, '|'
    call SetNewChar@0
    call ChangeCharAt@0

    ; -------- Clear one below torso --------
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx,2                  
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update right arm
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    mov eax, xCoord
    mov ebx, yCoord
    dec ebx 
    inc eax 
    mov ecx, '\'
    call SetNewChar@0
    call ChangeCharAt@0

    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx, 2
    inc eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update left arm
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    mov eax, xCoord
    mov ebx, yCoord
    dec ebx
    dec eax 
    mov ecx, '/'
    call SetNewChar@0
    call ChangeCharAt@0

    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx, 2
    dec eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update right leg
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    mov eax, xCoord
    mov ebx, yCoord
    sub ebx, 2
    inc eax 
    mov ecx, '\'
    call SetNewChar@0
    call ChangeCharAt@0

    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx, 3
    inc eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0

; Update left leg
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    mov eax, xCoord
    mov ebx, yCoord
    sub ebx, 2
    dec eax 
    mov ecx, '/'
    call SetNewChar@0
    call ChangeCharAt@0

    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx, 3
    dec eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0



    ret
UpdatePlayerBody ENDP



MoveLeft PROC

ret
MoveLeft ENDP



MoveRight PROC

ret
MoveRight ENDP
END 