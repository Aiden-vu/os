;******************************************
; bootloader.asm
; A Simple Bootloader
;******************************************

org 0x7c00
bits 16
start: jmp boot

;; constants and variables
msg db "Welcome to Aiden's Operating System!", 0ah, 0dh, 0h

boot:
    cli ; no interrupts
    cld ; all that we need to init
    hlt ; halt the system


; We need to have 512 so we need to clear the rest of the bytes with 0
times 510 - ($-$$) db 0
dw 0xAA55 ; Boot signature