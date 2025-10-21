;******************************************
; sample.asm
; A Sample Program
;******************************************
org 0x0
bits 16

MAX_CMD_LEN equ 64

start:
    mov ax, 0x50
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFF
    
    mov si, welcome_msg
    call print_string

shell_loop:
    ; Print prompt
    mov si, prompt
    call print_string
    
    ; Read command
    mov di, command_buffer
    call read_line
    
    ; Parse and execute command
    call execute_command
    jmp shell_loop

read_line:
    xor cx, cx              ; Character counter
.loop:
    xor ah, ah
    int 0x16                ; Get keystroke
    
    cmp al, 0x0D            ; Enter?
    je .done
    
    cmp al, 0x08            ; Backspace?
    je .backspace
    
    cmp cx, MAX_CMD_LEN     ; Buffer full?
    jge .loop
    
    ; Store character
    stosb
    inc cx
    
    ; Echo character
    mov ah, 0x0E
    int 0x10
    jmp .loop

.backspace:
    test cx, cx             ; At start?
    jz .loop
    
    dec di
    dec cx
    
    ; Move cursor back
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .loop

.done:
    xor al, al              ; Null terminate
    stosb
    mov si, newline
    call print_string
    ret

execute_command:
    mov si, command_buffer
    
    ; Check for "help" command
    mov di, cmd_help
    call strcmp
    jz .help
    
    ; Check for "clear" command
    mov di, cmd_clear
    call strcmp
    jz .clear
    
    ; Check for "about" command
    mov di, cmd_about
    call strcmp
    jz .about
    
    ; Unknown command
    mov si, unknown_msg
    call print_string
    ret

.help:
    mov si, help_msg
    call print_string
    ret

.clear:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    mov si, welcome_msg
    call print_string
    ret

.about:
    mov si, about_msg
    call print_string
    ret

; Compare strings (SI and DI)
strcmp:
    push si
    push di
.loop:
    lodsb
    mov bl, [di]
    inc di
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    jmp .loop
.equal:
    pop di
    pop si
    xor ax, ax              ; ZF = 1
    ret
.not_equal:
    pop di
    pop si
    or ax, 1                ; ZF = 0
    ret

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

welcome_msg db "MyOS v0.1", 0x0D, 0x0A, "Type 'help' for commands", 0x0D, 0x0A, 0
prompt db "$ ", 0
newline db 0x0D, 0x0A, 0
help_msg db "Commands: help, clear, about", 0x0D, 0x0A, 0
about_msg db "Simple OS - Learning Operating Systems", 0x0D, 0x0A, 0
unknown_msg db "Unknown command", 0x0D, 0x0A, 0

cmd_help db "help", 0
cmd_clear db "clear", 0
cmd_about db "about", 0

command_buffer times MAX_CMD_LEN + 1 db 0

times 512 - ($-$$) db 0