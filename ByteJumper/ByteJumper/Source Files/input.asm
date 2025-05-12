;----------------------------

; INPUT
;----------------------------
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib
INCLUDELIB C:\Irvine\Kernel32.lib
INCLUDELIB C:\Irvine\User32.lib

EXTERN GetAsyncKeyState@4 : PROC
EXTERN CreateThread@24 : PROC
EXTERN SetInputMsg@0 : PROC
EXTERN GetTickCount@0 : PROC
EXTERN SetFpsBuffer@0 : PROC
EXTERN Movement@0 : PROC
; THREAD HANDLING
EXTERN EnterCriticalSection@4 : PROC
EXTERN LeaveCriticalSection@4 : PROC
EXTERN InitializeCriticalSection@4 : PROC
EXTERN ExitThread@4 : PROC

.data
critSec DWORD 6 DUP(?)
threadID DWORD ?
inputThreadHandle DWORD ?
spaceStr BYTE "    SPACE    ", 0
leftStr BYTE "  LEFT KEY    ", 0
rightStr BYTE" RIGHT KEY    ", 0
spaceWasDown BYTE 0
prevTick   DWORD ?
currTick   DWORD ?
frameTime  DWORD ?
fpsBuffer  BYTE "     FPS:", 0
inputThreadRunning BYTE 1


.code
StartInputThread PROC

    ; Create the thread
    push 0                  ; lpThreadId (optional)
    push 0                  ; dwCreationFlags (run immediately)
    push 0                  ; lpParameter (none)
    push OFFSET PlayerInput ; lpStartAddress
    push 0                  ; dwStackSize (default)
    push 0                  ; lpThreadAttributes (default)
    call CreateThread@24
    push OFFSET critSec
    call InitializeCriticalSection@4 ; Used for locking threads so only one can run at a time

    mov inputThreadHandle, eax   ; Store handle if needed
    ret
  StartInputThread ENDP



 PlayerInput PROC
    ; Wait for game to load
    mov eax, 500
    call Delay
    ; Thread loop is here
      threadLoop_:
      mov dl, inputThreadRunning
      cmp dl, 0
      je endInputThread_
      call FrameCounter
    ; enter critical section
    
   
    push OFFSET critSec
    call EnterCriticalSection@4

; -- protected code here --
    call OnSpacePress ; Check for SPACE being pressed
    call OnMoveLeft   ; Check for A being pressed
    call OnMoveRight  ; Check for D being pressed
    ; leave critical section
    push OFFSET critSec
    call LeaveCriticalSection@4
   
     
    mov eax, 1   ; Time in milliseconds
    call Delay
    ; Main thread work
   jmp threadLoop_


   endInputThread_:
    push 0
    call ExitThread@4 

ret
   ret
PlayerInput ENDP


OnSpacePress PROC
    push 20h              ; Virtual-Key code for Spacebar
    call GetAsyncKeyState@4
    ; Return value in AX (low bit = 1 if pressed)
    test ax, 8000h         ; check high bit (key currently down)
    jz noSpace_

    ; Call movement proc in mechanics.asm
    mov edx, 2 ; EDX is direction to go 
    call Movement@0
    mov edx, offset spaceStr
    call SetInputMsg@0 ; Update input message to "SPACE"
    noSpace_:
    ret
    
OnSpacePress ENDP


OnMoveLeft PROC
    push 41h              ; Virtual-Key code for A
    call GetAsyncKeyState@4
    ; Return value in AX (low bit = 1 if pressed)
    test ax, 8000h         ; check high bit (key currently down)
    jz notLeft_
    mov edx, 3 ; EDX is direction to go 
    call Movement@0
  
    mov edx, offset leftStr
    call SetInputMsg@0 ; Update input message to "LEFT KEY"
    notLeft_:
    ret
    
OnMoveLeft ENDP

OnMoveRight PROC
    push 44h              ; Virtual-Key code for D
    call GetAsyncKeyState@4
    ; Return value in AX (low bit = 1 if pressed)
    test ax, 8000h         ; check high bit (key currently down)
    jz notRight_
    mov edx, 4 ; EDX is direction to go 
    call Movement@0
    mov edx, offset rightStr
    call SetInputMsg@0 ; Update input message to "RIGHT KEY"
    notRight_:
    ret
    
OnMoveRight ENDP


; For measuring FPS
FrameCounter PROC
 call GetTickCount@0
    mov currTick, eax

    ; Calculate frame time
    mov eax, currTick
    sub eax, prevTick
    mov frameTime, eax

    ; Store current time
    mov eax, currTick
    mov prevTick, eax

    ; Protect against divide-by-zero
    cmp frameTime, 0
    je skipPrint

    ; FPS = 1000 / frameTime
    mov eax, 1000
    xor edx, edx
    div frameTime           ; EAX = FPS

    ; Store FPS in EDX
    mov edx, eax
    call SetFpsBuffer@0     ; Store FPS value

skipPrint:
    ret
FrameCounter ENDP

EndInputThread PROC
mov inputThreadRunning, 0
ret
EndInputThread ENDP

END 
