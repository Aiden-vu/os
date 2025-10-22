;******************************************
; memory.inc
; Memory Management Functions
;******************************************

; Memory map for real mode:
; 0x00000-0x003FF : Real Mode IVT (Interrupt Vector Table)
; 0x00400-0x004FF : BIOS Data Area
; 0x00500-0x07BFF : Free (about 30KB)
; 0x07C00-0x07DFF : Bootloader
; 0x07E00-0x0FFFF : Free (about 32KB)
; 0x10000-0x9FFFF : Free (576KB) - Extended memory in real mode
; 0xA0000-0xFFFFF : Video memory, ROM, etc.

HEAP_START equ 0x10000
HEAP_SIZE equ 0x8000    ; 32KB heap

memory_init:
    push ax
    push es
    
    ; Detect memory using BIOS
    ; INT 0x12 returns KB of conventional memory in AX
    int 0x12
    mov [total_memory], ax
    
    ; Initialize simple heap
    mov word [heap_ptr], HEAP_START
    mov word [heap_end], HEAP_START + HEAP_SIZE
    
    pop es
    pop ax
    ret

memory_get_free:
    ; Returns free memory in KB in AX
    push bx
    push dx
    
    mov ax, [heap_end]
    mov bx, [heap_ptr]
    sub ax, bx
    
    ; Convert bytes to KB
    shr ax, 10
    
    pop dx
    pop bx
    ret

; Simple malloc implementation
; Input: AX = size in bytes
; Output: AX = pointer or 0 if failed
memory_alloc:
    push bx
    push dx
    
    mov bx, [heap_ptr]
    mov dx, bx
    add dx, ax
    
    ; Check if we have space
    cmp dx, [heap_end]
    ja .no_space
    
    ; Update heap pointer
    mov [heap_ptr], dx
    mov ax, bx
    jmp .done
    
.no_space:
    xor ax, ax
    
.done:
    pop dx
    pop bx
    ret

; Simple reset (no real free in this simple implementation)
memory_reset:
    push ax
    mov ax, HEAP_START
    mov [heap_ptr], ax
    pop ax
    ret

; Memory variables
total_memory dw 0
heap_ptr dw 0
heap_end dw 0