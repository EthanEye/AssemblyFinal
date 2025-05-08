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
CreatePlatform PROC
    mov xCoord, eax
    mov yCoord, ebx

    ; Store new x, y position at index and inc index
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
;mov eax, platformsX[ecx*4]    ; load value
;mov platformsX[ecx*4], eax    ; store value
; Set start platform x position at index = ECX new number = EAX
SetStartXY PROC


endStartXY_:

ret
SetStartXY ENDP


UpdatePlatforms PROC

ret
UpdatePlatforms ENDP


ClearPlatformXy PROC


ret
ClearPlatformXy ENDP

; Checks for avalible index and updates IndexX and IndexY



END