INCLUDE C:\Irvine\irvine\Irvine32.inc
INCLUDELIB C:\Irvine\irvine\Irvine32.lib
EXTERN ChangeCharAt@0 : PROC
EXTERN GetCharAt@0 : PROC
EXTERN GetPlayerXy@0 : PROC
EXTERN SetNewChar@0 : PROC

.data
P_WIDTH = 6    
; SET TO 6 PLATFORMS MAX 
; EACH FOR BYTES = 1 INDEX  
platformsX DWORD 36 DUP(0)      ; Keep track of x start positions for each platform
platformsY DWORD 36 DUP(0)      ; Keep track of y start positions for each platform
xCoord DWORD ?
yCoord DWORD ?
indexX DWORD 1
indexY DWORD 1
.code
; Start position: EAX = X, EBX = Y 
CreatePlatform PROC
    cmp eax, 110 ; If x is out of bounds dont try and create platform
    jg endCreatePlatform_
    cmp eax, 1 ; If x is out of bounds dont try and create platform
    jl endCreatePlatform_
    cmp ebx, 1 ; If y is out of bounds dont try and create platform
    jl endCreatePlatform_
    cmp ebx, 20 ; If y is out of bounds dont try and create platform
    jg endCreatePlatform_
    push eax
    push ebx
    
    ; Save start values for platform so it can be updated
    mov ecx, indexX 
    call SetStartX
    mov ecx, indexY 
    call SetStartY

    mov eax, cyan
    call SetTextColor

    mov cx, 2588h
    call SetNewChar@0

    pop ebx           ; EBX = start Y
    pop eax           ; EAX = start X
    mov esi, eax      ; ESI = original start X (used for comparison)
    add esi, P_WIDTH  ; ESI = end X

platform_loop:
    push eax
    push ebx

    call ChangeCharAt@0

    pop ebx
    pop eax

    inc eax
    cmp eax, esi       ; compare against startX + P_WIDTH
    jl platform_loop

    endCreatePlatform_:
    ret
CreatePlatform ENDP
;mov eax, platformsX[ecx*4]    ; load value
;mov platformsX[ecx*4], eax    ; store value
; Set start platform x position at index = ECX new number = EAX
SetStartX PROC
retryX_:
cmp ecx, 36
jg xOverflow_
; Check if index is full 
mov edx, platformsX[ecx*4] ; load value
cmp edx, 0        ; Zero means its empty index
jne endStartX_
mov platformsX[ecx*4], eax    ; store updated value
inc ecx
mov indexX, ecx
jmp endStartX_
xOverflow_:
call checkForZero ; Check to see if theres any zero is there is none that means theres already 6 plat forms
jmp retryX_
endStartX_:
ret
SetStartX ENDP

SetStartY PROC
retryY_:
cmp ecx, 36
jg yOverflow_
;Check if index is full 
mov edx, platformsY[ecx*4] ; load value
cmp edx, 0        ; Zero means its empty index
jne endStartY_
mov platformsY[ecx*4], ebx    ; store updated value
inc ecx
mov indexY, ecx
jmp endStartY_
yOverflow_:
mov eax, indexX
mov indexY, eax
jmp retryY_
endStartY_:
ret
SetStartY ENDP

UpdatePlatforms PROC


skipCreateNew_:
;Get start position for each platform and clear it then mov it relative to player
mov ecx, 0
startPLoop_:
inc ecx
cmp ecx, 36
je endStartPLoop_
mov eax, platformsX[ecx*4]    ; load X value
cmp eax, 0 ; if value at index is 0 then ignore (empty index) and loop again
je startPLoop_
mov ebx, platformsY[ecx*4]    ; load  Y value
push eax
push ebx
call ClearPlatformXy ; if not 0 then update platform position and clear out old position
pop ebx
pop eax
dec ebx ; Move platform down one
call CreatePlatform


endStartPLoop_:
ret
UpdatePlatforms ENDP


ClearPlatformXy PROC
; Set old values to 0
mov platformsX[ecx*4], 0
mov platformsY[ecx*4], 0

    mov cx, ' '
    call SetNewChar@0
    clearLoop_:
    push eax
    push ebx

    call ChangeCharAt@0

    pop ebx
    pop eax

    inc eax
    cmp eax, esi       ; compare against startX + P_WIDTH
    jl clearLoop_

ret
ClearPlatformXy ENDP

; Checks for avalible index and updates IndexX and IndexY
CheckForZero PROC

ret
CheckForZero ENDP



RandomXY PROC
    ; Generate random X
    push 80                ; Example: screen width = 80 columns
    call RandomRange       ; result in EAX (0 to 79)

    ; Save X in EAX
    push eax               ; temporarily store X

    ; Generate random Y
    push 25                ; Example: screen height = 25 rows
    call RandomRange       ; result in EAX (0 to 24)
    mov ebx, eax           ; store Y in EBX

    ; Restore X into EAX
    pop eax

    ret
RandomXY ENDP
END