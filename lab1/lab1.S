.org 0x100

.section .text

.code16


    movw $3, %ax
    int $0x10

    in $0x92, %al
    or $2, %al
    out %al, $0x92

    mov %cs, label_cs

    xor %eax, %eax
    mov        %cs, %ax
    shl        $4, %eax
    movw        %ax, CODE16_descr+2
    shr        $16, %eax
    movb        %al, CODE16_descr+4


    xor %eax, %eax
    movw %cs, %ax
    shl $4, %eax
    add $PROTECTED_MODE_ENTERY_POINT, %eax
    movl %eax, ENTERY_OFF


    xor %eax, %eax
    mov %cs, %ax
    shl $4, %eax
    add $GDT, %ax

    movl %eax, GDTR + 2

    lgdt GDTR

    cli

    in $0x70, %al
    or $0x80, %al
    out %al, $0x70

    mov %cr0, %eax
    or $1, %al
    mov %eax, %cr0

    .byte 0x66
    .byte 0xEA

    ENTERY_OFF:
        .long PROTECTED_MODE_ENTERY_POINT
        .short 0b00001000


PM_RETURN:

    mov %cr0, %eax
    and $0xFE, %al
    mov %eax, %cr0

    .byte 0xEA
    .word label1
    label_cs:
    .word 0

    label1:
    mov %cs, %ax
    mov %ax, %ds
    mov %ax, %es

    in         $0x70, %al
    and        $0x7F, %al
    out        %al, $0x70

    sti

    mov $9, %ah
    mov $endl, %dx
    int $0x21

    mov        $0x4C, %ah
    int        $0x21

    .p2align 3
    GDT:
        NULL_descr:
            .byte 0, 0, 0, 0, 0, 0, 0, 0
        CODE_descr:
            .byte 0xFF, 0xFF, 0x00, 0x00, 0x00, 0b10011010, 0b11001111, 0x00
        DATA_descr:
            .byte 0xFF, 0xFF, 0x00, 0x00, 0x00, 0b10010010, 0b11001111, 0x00
        VIDEO_descr:
            .byte 0xFF, 0xFF, 0x00, 0x80, 0x0B, 0b10010010, 0b01000000, 0x00
        CODE16_descr:
            .byte 0xFF, 0xFF, 0x00, 0x00, 0x00, 0b10011010, 0x00, 0x00
    GDTR:
        .short 39
        .long 0

    .code32
    PROTECTED_MODE_ENTERY_POINT:
    movw $0b00010000, %ax
    movw %ds, %bx
    movw %ax, %ds
    movw $0b00011000, %ax
    movw %ax, %es

    xor %esi, %esi
    movw %bx, %si
    shl $4, %esi
    add $message, %esi
    xor %edi, %edi
    movl $54, %ecx

    rep movsb

    jmp $32, $PM_RETURN

    endl:
        .ascii "\n\r$"
    message:
        .byte 'H', 0x35, 'e', 0x35, 'l', 0x35, 'l', 0x35, 'o', 0x35, 'w', 0x35
        .byte ' ', 0x35, 'f', 0x35, 'r', 0x35, 'o', 0x35, 'm', 0x35, ' ', 0x35
        .byte 'p', 0x35, 'r', 0x35, 'o', 0x35, 't', 0x35, 'e', 0x35, 'c', 0x35
        .byte 't', 0x35, 'e', 0x35, 'd', 0x35, ' ', 0x35, 'm', 0x35, 'o', 0x35
        .byte 'd', 0x35, 'e', 0x35, '!', 0x35
