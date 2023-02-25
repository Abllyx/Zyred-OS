global start_long_mode

section .text
bits 64

;   Starting the long_mode
start_long_mode:
    ;mov ax, 0
    ;mov ss, ax
    ;mov ds, ax
    ;mov es, ax
    ;mov fs, ax
    ;mov gs, ax
;
	;jmp .returned
;
	;hlt
    ; call rust main (with multiboot pointer in rdi)
    ;call rust_main

.returned:
    ; rust main returned, print `OS returned!`
	mov rax, 0x4f724f204f534f4f
	mov [0xb8000], rax
    mov rax, 0x4f724f754f744f65
    mov [0xb8008], rax
    mov rax, 0x4f214f644f654f6e
    mov [0xb8010], rax

	hlt

.error:
	mov dword [0x8000], 0x4f524f45
	mov dword [0x8004], 0x4f3a4f52
	mov dword [0x8008], 0x4f204f20

	mov byte [0xb800a], al
	
	hlt