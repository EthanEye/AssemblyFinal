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
index DWORD 1

.code
; Start position: EAX = X, EBX = Y 
; mov eax, platformsX[ecx*4]    ; load value
; mov platformsX[ecx*4], eax    ; store value
CreatePlatform PROC
    mov xCoord, eax
    mov yCoord, ebx

    ; Store first x, y position at index XY to keep track of each platform
    mov ecx, index
    mov platformsX[ecx*4], eax    ; store value
    mov platformsY[ecx*4], eax    ; store value
    inc ecx
    mov index, ecx
    
    mov cx, 2588h
    call SetNewChar@0

    mov ecx, 0
    ; Draw the new platform
    createLoop_:
    cmp ecx, 6
    jge endCreateLoop_
    mov eax, xCoord
    mov ebx, yCoord
    call ChangeCharAt@0
    dec xCoord       ;  move left instead of right
    inc ecx
    jmp createLoop_

endCreateLoop_:
ret
CreatePlatform ENDP




UpdatePlatforms PROC
mov ecx, 0        
    checkLoop_:
    cmp ecx, 36                   ; Number of platform slots
    jge endCheckLoop_
    mov eax, platformsX[ecx*4]    ; Load value at platformsX[esi]
    cmp eax, 0
    je skip_
    mov eax, platformsY[ecx*4]    ; Load value at platformsY[esi]
    call ClearPlatformXy          ; Clear platform and move down one
    ; index ESI is active (not zero)
    ; Do something here if platform is active
   
skip_:
    inc ecx
    loop checkLoop_
   



endCheckLoop_:
ret
UpdatePlatforms ENDP


ClearPlatformXy PROC


ret
ClearPlatformXy ENDP

; Checks for avalible index and updates IndexX and IndexY



END