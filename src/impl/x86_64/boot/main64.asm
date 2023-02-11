global start_long_mode
extern kernel_main

section .text
bits 64

;   Starting the long_mode
start_long_mode:
    mov ax, 0
    
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call kernel_main ;  main c file: './../kernel/kernel.c'

    hlt
