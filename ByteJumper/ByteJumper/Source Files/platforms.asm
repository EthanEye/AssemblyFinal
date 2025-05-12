INCLUDE C:\Irvine\irvine\Irvine32.inc
INCLUDELIB C:\Irvine\irvine\Irvine32.lib
EXTERN ChangeCharAt@0 : PROC
EXTERN GetCharAt@0 : PROC
EXTERN GetPlayerXy@0 : PROC
EXTERN SetNewChar@0 : PROC

.data
  
;PLATFORM ARRAYS:
platformsX DWORD 36 DUP(0)      ; Keep track of x start positions for each platform
platformsY DWORD 36 DUP(0)      ; Keep track of y start positions for each platform
xCoord DWORD ?
yCoord DWORD ?
spacer BYTE "   ", 0
index DWORD 0

.code
; Start position: EAX = X, EBX = Y 
; mov eax, platformsX[ecx*4]    ; load value
; mov platformsX[ecx*4], eax    ; store value
CreatePlatform PROC
    push esi
    ; Store new X and Y value (Start of where platform is drawn from)
    mov xCoord, eax
    mov yCoord, ebx
    ; Check if theres space for another platform
    mov ecx, -1
    scanForZero_:
    inc ecx
    cmp ecx, 7 ; 6 X and 6 y values ( 6 PLATFORMS MAX)
    je endCreatePlatform_
    ; Check if index is 0 (If theres no zeros platform cant be created yet ; already 6 platforms)
    mov eax, platformsX[ecx*4]
    cmp eax, 0
    jne scanForZero_
    ; If a Zero is found then It will create a new platform here given the X and Y position
    mov index, ecx   ; Store index where zero was found
    ; Pull parameters where we want the new platform to be spawned
    mov eax, xCoord
    mov ebx, yCoord
    ; Also store the new platform position 
    mov platformsX[ecx*4], eax    ; store X value
    mov platformsY[ecx*4], ebx    ; store Y value
    ; Platform is created here
    createPlatform_:
    mov esi, 0
    pLoop_:
    inc esi
    cmp esi, 6
    je endCreatePlatform_
    mov cx, 2588h
    call SetNewChar@0
    mov eax, xCoord
    mov ebx, yCoord
    inc eax
    mov xCoord, eax
    call ChangeCharAt@0
    jmp pLoop_
    endCreatePlatform_:
    pop esi
ret
CreatePlatform ENDP

UpdatePlatforms PROC
push esi

; Clear platforms off screen before values are updated then redrawn
call ClearPlatforms 


; This function is called when player is jumping to move platforms down
mov esi, 0
checkPLoop_:
cmp esi, 6
je endCheckPLoop_ 
; Check if index is 0
mov eax, platformsX[esi*4]
cmp eax, 0
je skipThisIndex_
mov ebx, platformsY[esi*4]
; If its not zero update the platform at that location
mov index, esi
mov xCoord, eax
mov yCoord, ebx
call UpdatePlatformXy
skipThisIndex_:
inc esi
jmp checkPLoop_ 
endCheckPLoop_:
; Redraw platforms
pop esi
ret
UpdatePlatforms ENDP


PlatformDebugger PROC 
  
  mov esi, 0              ; index

printLoop:
    cmp esi, 6
    jge endPrintLoop        ; done

    ; Load and print platformsX[esi]
    mov eax, platformsX[esi*4]
    call WriteInt
   
    ; Add space separator
    mov edx, offset spacer
    call WriteString
    ; Load and print platformsY[esi]
    mov eax, platformsY[esi*4]
    call WriteInt
    mov edx, offset spacer
    call WriteString
    inc esi
    jmp printLoop

endPrintLoop:

ret
PlatformDebugger ENDP
; Checks for avalible index and updates IndexX and IndexY


UpdatePlatformXy PROC
mov eax, xCoord 
mov ebx, yCoord
mov edx, index
dec ebx
; Delete plateform if y value is below this number
cmp ebx, 0
jle deletePlatform_
; Update new platform X  and Y
mov platformsX[edx*4], eax
mov platformsY[edx*4], ebx
jmp endUpdateP_
deletePlatform_:
; Deletes from arrays
mov platformsX[edx*4], 0
mov platformsY[edx*4], 0
endUpdateP_:

ret
UpdatePlatformXy ENDP

; Goes through platform array when play is jumping to delete every platform and redraw it in new location
ClearPlatforms PROC
    push esi
    mov esi, 0

  clearPLoop_:
    cmp esi, 6
    jge endClearLoop_   ; once we've done 6 slots, exit

    mov eax, platformsX[esi*4]
    cmp eax, 0
    je skipThisOne     ; if this slot is empty, skip
    
    mov index, esi
    
    call ClearPlatformAtIndex
    
skipThisOne:
    inc esi
    jmp clearPLoop_    ; go check the next slot

endClearLoop_:
    pop esi
    ret
ClearPlatforms ENDP

ClearPlatformAtIndex PROC
push esi
mov edx, index

mov cx, '?'
call SetNewChar@0

mov esi, 0
eraseLoop_:
cmp esi, 6
je endErase_
mov eax, platformsX[edx*4]
mov ebx, platformsY[edx*4]
call ChangeCharAt@0



endErase_:
pop esi
ret
ClearPlatformAtIndex ENDP

END