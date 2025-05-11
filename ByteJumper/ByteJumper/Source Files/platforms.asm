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
index DWORD 0

.code
; Start position: EAX = X, EBX = Y 
; mov eax, platformsX[ecx*4]    ; load value
; mov platformsX[ecx*4], eax    ; store value
CreatePlatform PROC
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
ret
CreatePlatform ENDP




UpdatePlatforms PROC
; This function is called when player is jumping to move platforms down
mov esi, 0
checkPLoop_:

cmp esi, 6
je endCheckPLoop_ 
; Check if index is 0
mov eax, platformsX[esi*4]
mov ebx, platformsY[esi*4]
cmp eax, 0
je skipThisIndex_
; If its not zero update the platform at that location
mov xCoord, eax
mov yCoord, ebx
;call ClearPlatformXy

skipThisIndex_:
inc esi


endCheckPLoop_:
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
   



    ; Load and print platformsY[esi]
    mov eax, platformsY[esi*4]
    call WriteInt
    

    inc esi
    jmp printLoop

endPrintLoop:

ret
PlatformDebugger ENDP
; Checks for avalible index and updates IndexX and IndexY



END