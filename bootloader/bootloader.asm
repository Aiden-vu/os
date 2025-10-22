;******************************************
; Bootloader.asm
; A Simple Bootloader
;******************************************
org 0x7C00
bits 16

KERNEL_SEGMENT equ 0x1000
KERNEL_OFFSET equ 0x0000
SECTORS_TO_READ equ 10

start:
    jmp short boot
    nop

boot:
    ; Disable interrupts during setup
    cli
    
    ; Setup stack (below bootloader)
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Setup segments
    mov ds, ax
    mov es, ax
    
    ; Enable interrupts
    sti
    cld
    
    ; Clear screen
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    ; Print loading message
    mov si, msg_loading
    call print_string
    
    ; Load kernel from disk
    call load_kernel
    
    ; Check if load was successful
    jc load_error
    
    ; Print success message
    mov si, msg_success
    call print_string
    
    ; Jump to kernel
    jmp KERNEL_SEGMENT:KERNEL_OFFSET

load_kernel:
    push ax
    push bx
    push cx
    push dx
    
    ; Setup parameters for disk read
    mov ax, KERNEL_SEGMENT
    mov es, ax
    xor bx, bx              ; ES:BX = destination
    
    mov ah, 0x02            ; Read sectors
    mov al, SECTORS_TO_READ ; Number of sectors
    mov ch, 0               ; Cylinder 0
    mov cl, 2               ; Start from sector 2 (after boot sector)
    mov dh, 0               ; Head 0
    mov dl, 0               ; Drive 0 (floppy A)
    
    int 0x13                ; BIOS disk read
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

load_error:
    mov si, msg_error
    call print_string
    
    ; Print error code
    mov al, ah
    call print_hex_byte
    
    mov si, msg_newline
    call print_string
    
    ; Halt system
    cli
    hlt

print_string:
    push ax
    push bx
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    xor bh, bh
    int 0x10
    jmp .loop
.done:
    pop bx
    pop ax
    ret

print_hex_byte:
    push ax
    push cx
    
    mov cx, ax
    shr al, 4
    call print_hex_digit
    
    mov ax, cx
    and al, 0x0F
    call print_hex_digit
    
    pop cx
    pop ax
    ret

print_hex_digit:
    push ax
    cmp al, 10
    jb .digit
    add al, 'A' - 10
    jmp .print
.digit:
    add al, '0'
.print:
    mov ah, 0x0E
    xor bh, bh
    int 0x10
    pop ax
    ret

msg_loading db "Loading kernel...", 0x0D, 0x0A, 0
msg_success db "Success! Starting kernel...", 0x0D, 0x0A, 0
msg_error db "Error loading kernel! Code: 0x", 0
msg_newline db 0x0D, 0x0A, 0

; Boot signature
times 510-($-$$) db 0
dw 0xAA55