global start
extern start_long_mode

section .text
bits 32

start:
    mov esp, stack_top

    ;	Save registers
    push edx
    push ecx
    push ebx
    push eax

	;	Disable PCI interrupts
    mov al,0xff
    out 0xa1, al
    out 0x21, al

    ;	Enable interrupts
    sti

    ;	Initialize edx to vga buffer ah attribute, al ch
    mov edx, 0xb8000
    mov ax, 0x0f60

    ;	ebx number of loops
    mov ebx,1000

.loop:
    ;	Output next character and attribte
    mov word [edx], ax

    ;	Incrment to next character with wrap
    inc al
    cmp al, 0x7f
    jne .loc
    mov al,60

.loc:
    add edx, 2
    and edx, 0x7ff
    or  edx, 0xb8000

    ;	Delay
    mov ecx, 0x2000

.delay:
    loop .delay

	;	Continue looping until ebx is 0
    dec ebx
    jnz .loop

	;	Disable interrupts
    cli

	;	Restore registers
    pop  eax
    pop  ebx
    pop  ecx
    pop  edx

	;	Multiboot info
    mov edi, ebx

	;	call the main test functions
	call load_multiboot
	call check_cpu_id
	call long_mode

	call set_up_pages
	call enable_paging
    call set_up_SSE

    ;	load the 64-bit GDT
    lgdt [gdt64.pointer]

    ;	update selectors
    mov ax, gdt64.data
    mov ss, ax
    mov ds, ax
    mov es, ax

    jmp gdt64.code_segment:start_long_mode


;	Check if the cpu id is supportet
check_cpu_id:
	pushfd
	pop eax
	
	mov ecx, eax

	xor eax, 1 << 21
	
	push eax
    popfd
    pushfd
    pop eax

    push ecx
    popfd

    xor eax, ecx
    jz .invalid_cpu_id

	ret 


;	if the cpu id isn't supported

.invalid_cpu_id:
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


;	Checking the long_mode with the function check_cpu_id
long_mode:
	mov eax, 0x80000000 ;	Check if the address: 0x80000000' is available.
	cpuid
	cmp eax, 0x80000001
	jb .faild_load_long_mode

	mov eax, 0x80000001
	cpuid
	cmp edx, 1 << 29
	jz .faild_load_long_mode

	ret

;	If the long_mode isnt Supported.
.faild_load_long_mode:
	mov al, 0x32 ;	Error code: '2'
	jmp error


;	Setting up the pages: 'p2', 'p3', 'p4'
set_up_pages:
	mov eax, p4
	or eax, 0b11

	mov [p4 + 511 *8], eax


	mov eax, p3
	or eax, 0b11

	mov [p4], eax


	mov eax, p2
	or eax, 0b11

	mov [p3], eax


	mov ecx, 0

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

set_up_SSE:
    ; check for SSE
    mov eax, 0x1
    cpuid
    test edx, 1<<25
    jz .no_SSE

    ; enable SSE
    mov eax, cr0
    and ax, 0xFFFB      ; clear coprocessor emulation CR0.EM
    or ax, 0x2          ; set coprocessor monitoring  CR0.MP
    mov cr0, eax
    mov eax, cr4
    or ax, 3 << 9       ; set CR4.OSFXSR and CR4.OSXMMEXCPT at the same time
    mov cr4, eax

    ret

.no_SSE:
    mov al, "a"
    jmp error


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
	resb 4096 * 2 ;	Reserve byte


stack_top:

;	read-only data
section .rodata

;	64-Bit flag
gdt64:
	dq 0

;	dq = define quad


.code_segment: equ $ - gdt64
	dq (1 << 44) | (1 << 47) | (1 << 41) | (1 << 43) | (1 << 53) ; 64-Bit code segment

;	output = 64-Bit constant. Like dw and dd

.data: equ $ - gdt64 ; new
    dq (1 << 44) | (1 << 47) | (1 << 41) ; data segment

.pointer:
	dw $ - gdt64 - 1
	dq gdt64

;	$ = current Address