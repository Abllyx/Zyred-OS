section .data

section .text
global start

start:
	mov eax, 1
	mov ebx, 1

	int 80h