INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib
EXTERN ChangeCharAt@0 : PROC
EXTERN GetCharAt@0 : PROC
EXTERN GetPlayerXy@0 : PROC
EXTERN SetNewChar@0 : PROC

.data
  
;PLATFORM ARRAYS:
platformsX DWORD 36 DUP(0)      ; Keep track of x start positions for each platform
platformsY DWORD 36 DUP(0)      ; Keep track of y start positions for each platform
xVal DWORD ?
yVal DWORD ?
spacer BYTE "   ", 0
indx DWORD 0

.code
; Start position: EAX = X, EBX = Y 
; mov eax, platformsX[ecx*4]    ; load value
; mov platformsX[ecx*4], eax    ; store value
CreatePlatform PROC
    push esi
    ; Store new X and Y value (Start of where platform is drawn from)
    mov xVal, eax
    mov yVal, ebx
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
    mov indx, ecx   ; Store index where zero was found
    ; Pull parameters where we want the new platform to be spawned
    mov eax, xVal
    mov ebx, yVal
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
    mov eax, xVal
    mov ebx, yVal
    inc eax
    mov xVal, eax
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
mov indx, esi
mov xVal, eax
mov yVal, ebx
call UpdatePlatformXy
skipThisIndex_:
inc esi
jmp checkPLoop_ 
endCheckPLoop_:

; Randomly generate new platforms

call RandomPlatform

; Redraw platforms

call RedrawPlatforms 


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
mov eax, xVal 
mov ebx, yVal
mov edx, indx
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
    
    mov indx, esi
    ; If index is not zero clear this platform
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
mov edx, indx
mov eax, platformsX[edx*4]
mov ebx, platformsY[edx*4]

mov cx, ' '
call SetNewChar@0
mov esi, 0
eraseLoop_:
cmp esi, 6
je endErase_
call ChangeCharAt@0
inc eax
inc esi
jmp eraseLoop_
endErase_:
pop esi
ret
ClearPlatformAtIndex ENDP



RedrawPlatforms PROC
push esi
mov esi, 0
redrawLoop_:
cmp esi, 6
jge endRedrawLoop_ 
mov eax, platformsX[esi*4]
cmp eax, 0
je skipThisRedraw_

mov indx, esi
; If index is not zero redraw this platform   
call RedrawPlatformAtIndex

skipThisRedraw_:
inc esi
jmp redrawLoop_

endRedrawLoop_:

pop esi
ret
RedrawPlatforms ENDP


RedrawPlatformAtIndex PROC
push esi
push ebx
mov edx, indx
mov eax, platformsX[edx*4]
mov ebx, platformsY[edx*4]
mov cx, 2588h
call SetNewChar@0
mov esi, 0
redrawIndexLoop_:
cmp esi, 6
jge endRedrawIndexLoop_ 
call ChangeCharAt@0
inc eax
inc esi
jmp redrawIndexLoop_
endRedrawIndexLoop_:
pop ebx
pop esi
ret
RedrawPlatformAtIndex ENDP


RandomPlatform PROC
    call GetPlayerXy@0
    cmp ebx, 5
    jle skipNewPlatform_
    mov eax, 100
    call  RandomRange
    mov ebx, 25
    call  CreatePlatform
    skipNewPlatform_:
    ret
RandomPlatform ENDP




END