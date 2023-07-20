;; Jon Woods
;; SE98699
;; The following program takes a number between -25 (backward) and 25 (forward) and a string of
;; 8 or more ASCII characters through user input. It then performs a letters-only Caesar
;; cipher encryption of said string, shifting letters by the received number.

;; C helper functions
extern freeMem
extern getInput
extern printf

section .data
	numPrompt db "Enter a shift value between -25 and 25 (included) " ; Prompt for shift value
	len_n equ $-numPrompt
	stringPrompt db "Enter a string greater than 8 characters: " ; Prompt for string
	len_s equ $-stringPrompt
	curr db "Current message: "
	len_c equ $-curr
	edited db "Encrypt message: "
	len_e equ $-edited
	fmt db "%s",10,0 ; formatter of arbitrary length for calls of printf

section .bss
	string resq 1  ; Input for the ASCII C-string to be encrypted, arbitrary length
	shiftVal resb 4	   ; Input for amount and direction of cipher, 3 ASCII characters and a line break

section .text
	global main

main: ; Receives user inputs
	call getShiftVal
	mov rbx, r8 ; Once shift value is finalized, store it with rbx pointer for safekeeping
	call getString
printString: ; Prints the input string as it is
	mov rax, 1
	mov rdi, 1
	mov rsi, curr
	mov rdx, len_c
	syscall

	mov rdi, fmt
	mov rsi, [string]
	xor rax, rax
	call printf
getCipher: ; Calls Caesar cipher on the input string and prints encryption
	mov rax, 1
	mov rdi, 1
	mov rsi, edited
	mov rdx, len_e
	syscall

	call shiftString ; Encrypt and display a new string

	mov rdi, fmt
	mov rsi, [string]
	xor rax, rax
	call printf
exit:
	;; Deallocate memory of input C-string
	mov rdi, [string]
	call freeMem

	mov rax, 60
	xor rdi, rdi
	syscall

getShiftVal:
	mov rax, 1
	mov rdi, 1
	mov rsi, numPrompt
	mov rdx, len_n
	syscall
	
	mov rax, 0 ; Receive user input for the shift value
	mov rdi, 0
	mov rsi, shiftVal
	mov rdx, 4
	syscall
	
	call addDigits ; Convert ASCII input to number

	;; Input validation
	cmp r8, -25
	jl getShiftVal ; First retry condition: shift value < -25

	cmp r8, 25
	jg getShiftVal ; Second retry condition: shift value > 25
	ret

addDigits: ; Converts an ASCII string to a number by reading digits and sign right to left
	xor rbx, rbx
	mov ebx, shiftVal
	mov ecx, 1 ; First digit goes in the ones place
	xor rax, rax
	xor r8, r8 ; r8 points to the ASCII-to-numerical conversion of ShiftVal
	
	mov al, byte[ebx+3] ; Last character: should be line break or null but check to be safe
	call checkByte

	mov al, byte[ebx+2] ; Third character: should be negative ones, line break or null
	call checkByte

	mov al, byte[ebx+1] ; Second character: should be negative tens, positive ones or null
	call checkByte
	
	mov al, byte[ebx] ; First character: should be positive ones, positive tens, or negative sign
	cmp al, 45 ; Check for negative sign
	je negate  ; If so, negate the stored value
	jmp checkByte ; If not, check whether it's a digit and return to main

checkByte:
	cmp al, 48
	jae checkForDigit
	ret ; Skip characters '\t'(9) through '/'(47) as non-digits

checkForDigit:
	cmp al, 57
	jbe isADigit
	ret ; Skip characters ':'(58) through '~'(126) as non-digits
	
isADigit: ; Converts ASCII digit to its numerical value, adds it to r8 at the correct place value
	sub rax, 48
	imul ecx
	add r8, rax
	xor rax, rax
	imul rcx, 10 ; Increase place value - ones to tens, etc.
	ret

negate:	; Changes the shift value stored in r8 to a negative number if the first byte == '-'
	neg r8
	ret

getString:
	mov rax, 1
	mov rdi, 1
	mov rsi, stringPrompt
	mov rdx, len_s
	syscall
	
	;; Receive user input and allocate memory as a C-string
	xor rax, rax
	call getInput
	mov [string], rax

	;; Input validation loop
	call getLength
	cmp rax, 8
	jb getString
	ret ; Return to main when the string is at least 8 non-null characters long

getLength:
	mov rsi, [string]
	xor rax, rax
lengthLoop:
	cmp byte[rsi], 0
	je breakpoint ; End loop when the null character '\0' is reached  
	inc rax
	inc rsi
	jmp lengthLoop

shiftString: ; Performs the Caesar cipher
	mov rsi, [string]
	mov rdi, [string]
	cld
	xor rax, rax
cipherLoop: ; Looping function loads each ASCII character byte from string 
	lodsb
	cmp rax, 0
	je breakpoint ; End loop when the null character '\0' is reached
	cmp rax, 65
	jb copy	; Encrypt characters '\t'(9) through '@'(64) as themselves
	cmp rax, 90
	ja notUppercase
uppercase: ; Encrypts uppercase letters based on shift value and checks if wrap functions are needed
	add rax, rbx
	cmp rax, 65
	jb wrapBackward
	cmp rax, 90
	ja wrapForward
	jmp copy

notUppercase: ; Finishes non-letter elimination of ASCII values above 'Z'(90)
	cmp rax, 97
	jb copy	; Encrypt characters '['(91) through '`'(96) as themselves
	cmp rax, 122
	ja copy	; Encrypt characters '{'(123) through '`'(126) as themselves
lowercase: ; Encrypts lowercase letters based on shift value and checks if wrap functions are needed
	add rax, rbx
	cmp rax, 97
	jb wrapBackward
	cmp rax, 122
	ja wrapForward
	jmp copy

wrapBackward: ; In backward encryption, wraps a byte past 'A' or 'a' back to respective alphabet
	add rax, 26
	jmp copy

wrapForward: ; In backward encryption, wraps a byte past 'Z' or 'z' back to respective alphabet
	sub rax, 26
	jmp copy

copy: ; Replaces the corresponding byte in string with its encryption and begins next loop iteration
	stosb
	jmp cipherLoop

breakpoint: ; Used for marking the end of looping functions, namely lengthLoop and cipherLoop
	ret
