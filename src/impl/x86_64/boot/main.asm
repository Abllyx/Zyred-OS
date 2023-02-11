global start
extern start_long_mode

section .text
bits 32

start:
	mov esp, stack_top

	call load_multiboot
	call cpuID
	call long_mode

	call set_up_pages
	call enable_paging

	lgdt [gdt64.pointer]
	jmp gdt64.code_segment:start_long_mode

	hlt


;	Check if the cpuid is supportet
cpuID:
	pushfd
	pop eax

	mov ecx, eax

	xor eax, 1 << 21
	
	push eax
	popfd

	pushfd
	pop eax

	pushfd
	push ecx
	
	cmp eax, ecx
	je .invalid_cpuID


;	cpuid isn't supported

.invalid_cpuID:
	mov al, 0x31 ;	Error code: '1'
	jmp error


;	If the multiboot is not there, 'kernal' cannot be executed properly and it gives an error in the 'error' function!
load_multiboot:
	cmp eax, 0x36d76289
	jne .faild_load_multiboot

	ret

.faild_load_multiboot:
	mov al, 0x30 ;	Error code: '0'
	jmp error

;	Checking the long_mode with the function cpuID
long_mode:
	mov eax, 0x80000000 ;	Check if the address: 0x80000000' is available.
	cpuID
	cmp eax, 0x80000001
	jb .faild_load_long_mode

	mov eax, 0x80000001
	cpuID
	cmp edx, 1 << 29
	jz .faild_load_long_mode

	ret

;	If the long_mode isnt Supported.
.faild_load_long_mode:
	mov al, 0x32 ;	Error code: '2'
	jmp error


;	'cr0-4' are register to enable paging
;	with enable paging we can entering long_mode
enable_paging:
	mov eax, p4
	mov cr3, eax

	mov eax, cr4
	or eax, 1 << 5

	mov cr4, eax

	mov ecx, 0xC0000080
	
	rdmsr
	or eax, 1 << 8

	wrmsr

	mov eax, cr0
	or eax, 1 << 31

	mov cr0, eax

	ret

;	If an error occurs, this function can be called! It outputs: 'ERR: 'error msg'' and stops!
error:
	mov dword [0x8000], 0x4f524f45
	mov dword [0x8004], 0x4f3a4f52
	mov dword [0x8008], 0x4f204f20

	mov byte [0xb800a], al
	
	hlt


;	Setting up the pages: 'p2', 'p3', 'p4'
set_up_pages:
	mov eax, p3
	or eax, 0b11

	mov [p4], eax

	mov eax, p2
	or eax, 0b11

	mov [p3], eax

	ret

;	Maping a P2 and calculate the start address of the page
.map_p2:
	mov eax, 0x200000
	
	mul ecx
	or eax, 0b10000011

	mov [p2 + ecx * 8], eax	;	every entry is 8 byte large

	inc ecx

	cmp ecx, 512
	jne .map_p2

	ret


section .bss

align 4096

;	reserves the amount of bytes without initializing! 
p4:
	resb 4096

p3:
	resb 4096

p2:
	resb 4096


;	Stacks don't need to be initialized because they can be 'pop' and 'push'.
stack_bottom:
	resb 64 ;	Reserve byte


stack_top:

;	read-only data
section .rodata

;	64-Bit flag
gdt64:
	dq 0

;	dq = define quad


.code_segment: equ $ - gdt64
	dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; 43-Bit segment

;	output = 64-Bit constant. Like dw and dd


.pointer:
	dw $ - gdt64 - 1
	dq gdt64

;	$ = current Address