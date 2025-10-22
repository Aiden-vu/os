;******************************************
; screen.inc
; Screen/Display Functions
;******************************************

screen_init:
    push ax
    call screen_clear
    pop ax
    ret

screen_clear:
    push ax
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    pop ax
    ret

screen_print:
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

screen_print_hex:
    push ax
    push bx
    push cx
    
    mov bx, ax
    mov cx, 4
    
.loop:
    rol bx, 4
    mov al, bl
    and al, 0x0F
    
    cmp al, 10
    jb .digit
    add al, 'A' - 10
    jmp .print
.digit:
    add al, '0'
.print:
    mov ah, 0x0E
    push bx
    xor bh, bh
    int 0x10
    pop bx
    
    dec cx
    jnz .loop
    
    pop cx
    pop bx
    pop ax
    ret

screen_newline:
    push ax
    push si
    mov si, .nl
    call screen_print
    pop si
    pop ax
    ret
.nl db 0x0D, 0x0A, 0