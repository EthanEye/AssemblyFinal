;----------------------------

; :INPUT
;----------------------------
INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
EXTERN GetAsyncKeyState@4 : PROC
EXTERN CreateThread@24 : PROC
EXTERN SetPlayerPos@0 : PROC
EXTERN SetInputMsg@0 : PROC
EXTERN GetTickCount@0 : PROC
EXTERN SetFpsBuffer@0 : PROC
EXTERN Jump@0 : PROC
; THREAD HANDLING
EXTERN EnterCriticalSection@4 : PROC
EXTERN LeaveCriticalSection@4 : PROC
EXTERN InitializeCriticalSection@4 : PROC


.data
critSec DWORD 6 DUP(?)
threadID DWORD ?
threadHandle DWORD ?
spaceStr BYTE "   (SPACE)    ", 0
leftStr BYTE " (LEFT KEY)    ", 0
rightStr BYTE"(RIGHT KEY)    ", 0

prevTick   DWORD ?
currTick   DWORD ?
frameTime  DWORD ?
fpsBuffer  BYTE "     FPS:", 0


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

    mov threadHandle, eax   ; store handle if needed
    ret
  StartInputThread ENDP



 PlayerInput PROC
    ; Player start head position
    mov eax, 5
    mov ebx, 56
    call SetPlayerPos@0
    ; Thread loop is here
      ThreadLoop_:
     
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
   
     
    mov eax, 1   ; time in milliseconds
    call Delay
    ; Main thread work
   jmp ThreadLoop_
   ret
PlayerInput ENDP


OnSpacePress PROC
    push 20h              ; Virtual-Key code for Spacebar
    call GetAsyncKeyState@4
    ; Return value in AX (low bit = 1 if pressed)
    test ax, 8000h         ; check high bit (key currently down)
    jz noSpace_

    ; Call jump proc in mechanics.asm
    call Jump@0
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

 
    ; Do something here

  
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

    ; Do something here

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

END 
