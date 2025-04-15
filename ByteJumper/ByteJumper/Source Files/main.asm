;----------------- Copy from here ---------------
; MASM Template
; <EthanEye>
; 3/6/2025
; Create a template for assembler files.
.386P
.model flat

extern   _ExitProcess@4: near
extern writeNumber: near
extern initialize_console: near

.data

fib1 dd 0 ; init fib 1
fib2 dd 1 ; init fib 2
count dd 0 ;
 

.code
main PROC near
_main:

call initialize_console



	push 0
	call	_ExitProcess@4

main ENDP


END
;----------------- End Copy here ---------------
