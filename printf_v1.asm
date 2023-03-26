;.model flat, C

;MyPrintf          proto fmtStr: ptr, args: vararg

section .data

example_str:		db 'lets celebrate and suck some dick', 0

format_str: 		db "%%%%%%%x %s", 10d, 0	

mask:				db 'h'

buffer:             times 64 db 's'
end_buf: 			equ $
len_buf:			db 64

number_buf:         times 16 db 0			        ; for translator to store the number to print

rev_number_buf:     times 16 db 0		            ; for reversing number string

message_error:		db 10d, "Error: Unexpected symbol after %", 10d, 0

;--------------------------------------------------
section .rodata

jump_table:
						dq PutNum.Bin
						dq PutChar.arg
						dq PutDecimal
times ('o' - 'd' - 1)   dq PutError
						dq PutNum.Oct
times ('s' - 'o' - 1)   dq PutError
						dq PutString
times ('x' - 's' - 1)   dq PutError
						dq PutNum.Hex

;------------------------------------------------

section .text

global MyPrint

MyPrint:
	;mov rdi, format_str
	;mov rsi, -191932321
	;mov rdx, example_str

	pop r15					; saving return address

	push r9 				; due to the call of the printf, first 6 args are being stored in the following registers			
	push r8					; other arguments are located in stack
	push rcx
	push rdx
	push rsi 																					
	push rdi																																													
	
	mov r9, buffer			; buf pointer

	call HandleFormatStr

	cmp r9, buffer
	jbe .empty_buf

	call PrintBuf

.empty_buf:
	pop rdi 				; balancing stack by deleting 6 args from it
	pop rsi
	pop rdx
	pop rcx
	pop r8
	pop r9

	push r15

	ret
	;mov rax, 0x3c
	;mov rdi, 0
	;syscall					; exit


HandleFormatStr:

	push rbp
	mov rbp, rsp

	add rbp, 16
	mov rdi, [rbp] 		; rdi = adress of format string
	add rbp, 8			; rbp = adress of first arg after format line

.loop:
	mov al, byte [rdi]	; al = *tmpl_string

	cmp al, 0			; if al == \0 then return
	je .end

	cmp al, '%'			; if al == % then handle argument
	jne .default_sym

	call HandleArg

	jmp .loop

.default_sym:
	call PutChar.format_line		; print char
	
	inc rdi							; next sym
	jmp .loop

.end:
	pop rbp
	ret


HandleArg:
    inc rdi
	xor rax, rax
    mov al, byte [rdi]
    
    cmp al, '%'
    je .put_percent

	push .end

    cmp al, 'b'
    jb PutError

    cmp al, 'x'
    ja PutError

	jmp [jump_table + (8 * (rax - 'b'))]

.put_percent:
    call PutChar.format_line

.end:
	inc rdi		; next sym
    ret


PutError:
    push rcx     ; syscall destroys rcx and r11, so restore them
	push r11

	;push rsi
	push rdx
	push rdi
	push rax

	mov rsi, message_error
	mov rdx, 34  ; error message len
	mov rdi, 1	 ; stdout
	mov rax, 1   ; syscall for write()

	syscall

	pop rax
	pop rdi
	pop rdx
	;pop rsi

	pop r11
	pop rcx

    ret



PutChar:

.arg:
	mov rsi, rbp
	add rbp, 8
	jmp .default

.format_line:
	mov rsi, rdi

.default:
    call AddSymToBuf
	ret


PutString:
	mov rsi, [rbp]
	add rbp, 8

.loop:
	cmp al, 0
	je .end

	call PutChar.default

	inc rsi
	mov al, [rsi]
	jmp .loop

.end:
	ret


CheckNegative:
	xor r13, r13
	cmp rax, 00h
	jge .positive

	mov r13, 1
	neg rax

.positive:
	ret


PutDecimal:
.get_number:
	xor rax, rax

	mov rax, [rbp]
	add rbp, 8

	call CheckNegative

	mov r10, number_buf
	mov rbx, 10			; max num signs
	push rbx
	mov ecx, 10	
.loop_division:
	xor edx, edx
	div ecx
	add dx, '0'
	mov [r10], dx
	inc r10

	dec bl
	cmp bl, 00h
	jne .loop_division

	pop rbx
	dec rbx			; buf + len - 1
	mov r10, number_buf
.skip_nulls:
	cmp byte [r10 + rbx], '0'
	jne .check_neg
	dec bl
	cmp bl, 00h
	je .check_neg
	jmp .skip_nulls

.check_neg:
	cmp r13, 1
	jne .positive

	mov byte [r9], '-'
	inc r9

.positive:

.reverse_num:
	inc rbx						; to print last elem
.loop_reverse:
	mov al, byte [r10+rbx-1]
	mov byte [r9], al
	inc r9

	cmp bl, 00h
	dec bl
	jne .loop_reverse
	ret

PutNum:

.Oct:
	xor rbx, rbx
	mov cl, 3			; shift left
	mov byte [mask], 111b
	mov bl, 11			; num signs
	jmp .get_number

.Bin:
	xor rbx, rbx
	mov cl, 1
	mov byte [mask], 1b
	mov bl, 32
	jmp .get_number

.Hex:
	xor rbx, rbx
	mov cl, 4
	mov byte [mask], 1111b
	mov bl, 8
	jmp .get_number

.get_number:

	xor rax, rax

	mov rax, [rbp]
	add rbp, 8

	call CheckNegative

;check_bufsize
	push rax

	mov rax, end_buf
	sub rax, r9
	cmp bl, al

	pop rax

	jb .num_to_buf

	call PrintBuf
	mov r9, buffer

.num_to_buf:
mov r10, number_buf

push rbx
.loop_division:
	mov edx, eax
	and edx, [mask]
	add dx, '0'
	mov [r10], dx
	inc r10

	shr eax, cl

	dec bl
	cmp bl, 00h
	jne .loop_division

pop rbx
dec rbx			; buf + len - 1
mov r10, number_buf
.skip_nulls:
	cmp byte [r10 + rbx], '0'
	jne .reverse_num
	dec bl
	cmp bl, 00h
	je .reverse_num
	jmp .skip_nulls

.reverse_num:
	cmp r13, 1
	jne .positive;

	mov byte [r9], '-'
	inc r9

.positive:

inc rbx						; to print last elem
.loop_reverse:
	mov al, byte [r10+rbx-1]
	cmp al, '9'
	jbe .not_a_letter

	add al, 7				; make a letter in hex
.not_a_letter:
	mov byte [r9], al
	inc r9

	cmp bl, 00h
	dec bl
	jne .loop_reverse

	ret


AddSymToBuf:
	cmp r9, end_buf
	jb .add_sym

	call PrintBuf
	mov r9, buffer

.add_sym:
	mov al, byte [rsi]
	mov [r9], al
	inc r9
	
	ret

PrintBuf:

	push rcx     ; syscall destroys rcx and r11, so restore them
	push r11

	push rsi
	push rdx
	push rdi
	push rax

	mov rsi, buffer
	mov rdx, r9 		   	; msg len
	sub rdx, buffer
	mov rdi, 1	 		   	; stdout
	mov rax, 1       	 	; syscall for write()

	syscall

	pop rax
	pop rdi
	pop rdx
	pop rsi

	pop r11
	pop rcx

	ret