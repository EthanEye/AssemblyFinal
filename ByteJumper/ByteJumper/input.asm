;----------------------------

; :INPUT
;----------------------------



INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib

EXTERN CreateThread@24 : PROC
EXTERN SetPlayerPos@0 : PROC
.data
threadID DWORD ?
threadHandle DWORD ?


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

    mov threadHandle, eax   ; store handle if needed
    ret
  StartInputThread ENDP



 PlayerInput PROC
    ; Do your thread work here
      ThreadLoop_:
    

    mov eax, 1   ; time in milliseconds
    call Delay
    ; Main thread work
   jmp ThreadLoop_
   ret
PlayerInput ENDP


OnSpacePress PROC

ret
OnSpacePress ENDP


END 
