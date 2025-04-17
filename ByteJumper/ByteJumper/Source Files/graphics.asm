INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
.data
bigText1 BYTE " ______     __  __     ______   ______          __     __  __     __    __     ______   ______     ______    ", 10,0  
bigText2 BYTE "/\  == \   /\ \_\ \   /\__  _\ /\  ___\        /\ \   /\ \/\ \   /\ -./  \    /\  == \ /\  ___\   /\  == \  ", 10,0 
bigText3 BYTE "\ \  __<   \ \____ \  \/_/\ \/ \ \  __\       _\_\ \  \ \ \_\ \  \ \ \-./\ \  \ \  _-/ \ \  __\   \ \  __< " , 10,0 
bigText4 BYTE " \ \_____\  \/\_____\    \ \_\  \ \_____\    /\_____\  \ \_____\  \ \_\ \ \_\  \ \_\    \ \_____\  \ \_\ \_\", 10, 0
bigText5 BYTE "  \/_____/   \/_____/     \/_/   \/_____/    \/_____/   \/_____/   \/_/  \/_/   \/_/     \/_____/   \/_/ /_/ ", 10,0                                                                                                            

.code

; Welcome Screen Message, "Play Button", Title Screen, Rules etc...
GameStart PROC
    mov edx, OFFSET bigText1
    call WriteString
    mov edx, OFFSET bigText2
    call WriteString
    mov edx, OFFSET bigText3
    call WriteString
    mov edx, OFFSET bigText4
    call WriteString
    mov edx, OFFSET bigText5
    call WriteString
    call WaitMsg
    
    ret
GameStart ENDP


END GameStart