;******************************************
; kernel.asm
; Main Kernel Entry Point
;******************************************
org 0x0000
bits 16

KERNEL_STACK equ 0xFFFF

start:
    ; Setup segments
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, KERNEL_STACK
    
    ; Initialize screen
    call screen_init
    
    ; Print welcome message
    mov si, welcome_msg
    call screen_print
    
    ; Initialize memory manager
    call memory_init
    
    ; Start shell
    call shell_main
    
    ; Should never reach here
    cli
    hlt

welcome_msg db "MyOS v0.2 - Enhanced", 0x0D, 0x0A, 0x0A, 0

;******************************************
; Shell Implementation
;******************************************
MAX_CMD_LEN equ 128
command_buffer times MAX_CMD_LEN + 1 db 0
cmd_args times MAX_CMD_LEN + 1 db 0

shell_main:
    mov si, shell_ready_msg
    call screen_print
    
.loop:
    ; Print prompt
    mov si, prompt
    call screen_print
    
    ; Read command
    mov di, command_buffer
    call read_line
    
    ; Parse and execute
    call parse_command
    call execute_command
    
    jmp .loop

parse_command:
    mov si, command_buffer
    mov di, cmd_args
    
    ; Skip leading spaces
.skip_space:
    lodsb
    cmp al, ' '
    je .skip_space
    cmp al, 0
    je .done
    
    ; Copy command name
    dec si
    mov di, command_buffer
.copy_cmd:
    lodsb
    cmp al, ' '
    je .found_space
    cmp al, 0
    je .done
    stosb
    jmp .copy_cmd
    
.found_space:
    xor al, al
    stosb
    
    ; Copy arguments
    mov di, cmd_args
.copy_args:
    lodsb
    cmp al, 0
    je .done
    stosb
    jmp .copy_args
    
.done:
    xor al, al
    stosb
    ret

execute_command:
    mov si, command_buffer
    
    ; Check for empty command
    lodsb
    or al, al
    jz .done
    
    ; Reset SI
    mov si, command_buffer
    
    ; Check commands
    mov di, cmd_help
    call strcmp
    jz cmd_help_exec
    
    mov di, cmd_clear
    call strcmp
    jz cmd_clear_exec
    
    mov di, cmd_about
    call strcmp
    jz cmd_about_exec
    
    mov di, cmd_mem
    call strcmp
    jz cmd_mem_exec
    
    mov di, cmd_echo
    call strcmp
    jz cmd_echo_exec
    
    mov di, cmd_reboot
    call strcmp
    jz cmd_reboot_exec
    
    ; Unknown command
    mov si, unknown_msg
    call screen_print
    
.done:
    ret

;******************************************
; Command Implementations
;******************************************
cmd_help_exec:
    mov si, help_msg
    call screen_print
    ret

cmd_clear_exec:
    call screen_clear
    mov si, welcome_msg
    call screen_print
    ret

cmd_about_exec:
    mov si, about_msg
    call screen_print
    ret

cmd_mem_exec:
    mov si, mem_msg
    call screen_print
    
    ; Get memory info
    call memory_get_free
    call screen_print_hex
    mov si, kb_msg
    call screen_print
    
    ret

cmd_echo_exec:
    mov si, cmd_args
    call screen_print
    mov si, newline
    call screen_print
    ret

cmd_reboot_exec:
    mov si, reboot_msg
    call screen_print
    
    ; Wait a moment
    mov cx, 0xFFFF
.wait:
    loop .wait
    
    ; Reboot via keyboard controller
    mov al, 0xFE
    out 0x64, al
    
    ; If that fails, triple fault
    cli
    lidt [invalid_idt]
    int 3

invalid_idt:
    dw 0
    dd 0

;******************************************
; Input Functions
;******************************************
read_line:
    push ax
    push cx
    push di
    
    xor cx, cx
.loop:
    xor ah, ah
    int 0x16
    
    cmp al, 0x0D
    je .done
    
    cmp al, 0x08
    je .backspace
    
    cmp al, 0x09
    je .tab
    
    cmp cx, MAX_CMD_LEN
    jge .loop
    
    ; Store and echo character
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .loop

.backspace:
    test cx, cx
    jz .loop
    
    dec di
    dec cx
    
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .loop

.tab:
    ; Tab completion placeholder
    jmp .loop

.done:
    xor al, al
    stosb
    mov si, newline
    call screen_print
    
    pop di
    pop cx
    pop ax
    ret

;******************************************
; String Functions
;******************************************
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
    xor ax, ax
    ret
.not_equal:
    pop di
    pop si
    or ax, 1
    ret

;******************************************
; Data Section
;******************************************
shell_ready_msg db "Type 'help' for available commands", 0x0D, 0x0A, 0x0A, 0
prompt db "myos> ", 0
newline db 0x0D, 0x0A, 0
kb_msg db " KB free", 0x0D, 0x0A, 0

help_msg db "Available commands:", 0x0D, 0x0A
         db "  help      - Show this help", 0x0D, 0x0A
         db "  clear     - Clear screen", 0x0D, 0x0A
         db "  about     - About this OS", 0x0D, 0x0A
         db "  mem       - Show memory info", 0x0D, 0x0A
         db "  echo TEXT - Echo text", 0x0D, 0x0A
         db "  reboot    - Reboot system", 0x0D, 0x0A, 0

about_msg db "MyOS v0.2", 0x0D, 0x0A
          db "A simple operating system for learning", 0x0D, 0x0A
          db "Written in x86 assembly (16-bit real mode)", 0x0D, 0x0A, 0

mem_msg db "Free memory: ", 0
reboot_msg db "Rebooting...", 0x0D, 0x0A, 0
unknown_msg db "Unknown command. Type 'help' for commands.", 0x0D, 0x0A, 0

cmd_help db "help", 0
cmd_clear db "clear", 0
cmd_about db "about", 0
cmd_mem db "mem", 0
cmd_echo db "echo", 0
cmd_reboot db "reboot", 0

;******************************************
; Include Files - MUST BE AT THE END
;******************************************
%include "include/screen.inc"
%include "include/memory.inc"

; Pad to full sector
times 512*10-($-$$) db 0