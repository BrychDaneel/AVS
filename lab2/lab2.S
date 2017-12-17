.org 0x100

.section .text

.code16

    movw $3, %ax
    int $0x10

    movb $9, %ah
    movw $endl, %dx
    int $0x21

    movw %cs, label_cs

    xor %eax, %eax
    mov %cs, %ax
    shl $4, %eax
    add $GDT, %ax

    movl %eax, GDTR + 2

    lgdt GDTR

    xor %eax, %eax
    mov        %cs, %ax
    shl        $4, %eax
    movw        %ax, CODE_descr+2
    shr        $16, %eax
    movb        %al, CODE_descr+4


    xor %eax, %eax
    mov        %cs, %ax
    shl        $4, %eax
    movw        %ax, CODE16_descr+2
    shr        $16, %eax
    movb        %al, CODE16_descr+4


    xor %eax, %eax
    mov        %cs, %ax
    shl        $4, %eax
    movw        %ax, DATA_descr+2
    shr        $16, %eax
    movb        %al, DATA_descr+4


    xor %eax, %eax
    mov %cs, %ax
    shl $4, %eax
    add $TSS_0, %eax
    movw %ax, GDT_TSS0 + 2
    shr $16, %eax
    movb %al, GDT_TSS0 + 4


    xor %eax, %eax
    mov %cs, %ax
    shl $4, %eax
    add $TSS_1, %eax
    movw %ax, GDT_TSS1 + 2
    shr $16, %eax
    movb %al, GDT_TSS1 + 4

    xor %eax, %eax
    mov %cs, %ax
    shl $4, %eax
    add $STACK, %eax
    movw %ax, STACK_descr + 2
    shr $16, %eax
    movb %al, STACK_descr + 4

    //открытие линии A20
    mov $2, %al
    out %al, $0x92

    cli

    in $0x70, %al
    or $0x80, %al
    out %al, $0x70

    mov %cr0, %eax
    or $1, %al
    mov %eax, %cr0

    .byte 0x66
    .byte 0xEA
    .long PROTECTED_MODE_ENTERY_POINT
    .short CODE_SEL


PM_RETURN:
    // переключиться в реальный режим RM
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

    in $0x70, %al
    and $0x7F, %al
    out %al, $0x70

    sti

    mov $0x4C, %ah
    int $0x21

    endl:
        .ascii "\n\r\n\r\n\r\n\r\n\r\n\r$"

    .p2align 3
    GDT:

        NULL_SEL = . - GDT
        NULL_descr:
            .byte 0, 0, 0, 0, 0, 0, 0, 0

        CODE_SEL = . - GDT
        CODE_descr:
            .byte 0xFF, 0xFF, 0x00, 0x00, 0x00, 0b10011010, 0b11001111, 0x00

        CODE16_SEL = . - GDT
        CODE16_descr:
            .byte 0xFF, 0xFF, 0x00, 0x00, 0x00, 0b10011010, 0x00, 0x00

        DATA_SEL = . - GDT
        DATA_descr:
            .byte 0xFF, 0xFF, 0x00, 0x00, 0x00, 0b10010010, 0b11001111, 0x00

        STACK_SEL = . - GDT
        STACK_descr:
            .byte 0xFF, 0xFF, 0x00, 0x00, 0x00, 0b10010010, 0b11001111, 0x00

        VIDEO_SEL = . - GDT
        VIDEO_descr:
            .byte 0xFF, 0xFF, 0x00, 0x80, 0x0B, 0b10010010, 0b01000000, 0x00

        TSS0_SEL = . - GDT
        GDT_TSS0:
            .byte 0x067, 0, 0, 0, 0, 0b10001001, 0b01000000, 0

        TSS1_SEL = . - GDT
        GDT_TSS1:
            .byte 0x067, 0, 0, 0, 0, 0b10001001, 0b01000000, 0

        GDT_SIZE = . - GDT

        TSS_0:
            .space 0x68, 0
        TSS_1:
            .long    0,0,0,0,0,0,0,0
            .long    task1
            .long    0,0,0,0,0,ST2,0,0,0
            .long    VIDEO_SEL,CODE_SEL,STACK_SEL,DATA_SEL,0,0
            .long    0
            .long    0

    GDTR:
        .short GDT_SIZE - 1
        .long 0

    .code32
    PROTECTED_MODE_ENTERY_POINT:

        xor %eax, %eax
        movw $DATA_SEL, %ax
        movw %ax, %ds
        movw $VIDEO_SEL, %ax
        movw %ax, %es
        movw $STACK_SEL, %ax
        movw %ax, %ss
        movl $ST1, %eax
        movl %eax, %esp

        xor %eax, %eax
        mov $TSS0_SEL, %ax
        ltr %ax

    task0:

        mov $message1_1, %esi
        mov $0, %edi
        movl $len1_1, %ecx
        rep movsb

        jmp $TSS1_SEL, $0

        mov $message1_2, %esi
        mov $320, %edi
        movl $len1_2, %ecx
        rep movsb

        jmp $TSS1_SEL, $0

        mov $message1_3, %esi
        mov $640, %edi
        movl $len1_3, %ecx
        rep movsb

        jmp $TSS1_SEL, $0

        /*mov $2000000, %ecx
        self1:
            loop self1*/

        jmp $CODE16_SEL, $PM_RETURN

    task1:

        mov $message2_1, %esi
        mov $160, %edi
        movl $len2_1, %ecx
        rep movsb

        jmp $TSS0_SEL, $0

        mov $message2_2, %esi
        mov $480, %edi
        movl $len2_2, %ecx
        rep movsb

        jmp $TSS0_SEL, $0

        mov $message2_3, %esi
        mov $800, %edi
        movl $len2_3, %ecx
        rep movsb

        jmp $TSS0_SEL, $0


    message1_1:
        .byte 'M', 0x35, 'e', 0x35, 's', 0x35, 'a', 0x35, 'g', 0x35, 'e', 0x35
        .byte '1', 0x35, ' ', 0x35
        .byte 'f', 0x35, 'r', 0x35, 'o', 0x35, 'm', 0x35, ' ', 0x35
        .byte 't', 0x35, 'a', 0x35, 's', 0x35, 'k', 0x35, '1', 0x35, '!', 0x35
        len1_1 = . - message1_1
    message1_2:
        .byte 'M', 0x35, 'e', 0x35, 's', 0x35, 'a', 0x35, 'g', 0x35, 'e', 0x35
        .byte '2', 0x35, ' ', 0x35
        .byte 'f', 0x35, 'r', 0x35, 'o', 0x35, 'm', 0x35, ' ', 0x35
        .byte 't', 0x35, 'a', 0x35, 's', 0x35, 'k', 0x35, '1', 0x35, '!', 0x35
        len1_2 = . - message1_2
    message1_3:
        .byte 'M', 0x35, 'e', 0x35, 's', 0x35, 'a', 0x35, 'g', 0x35, 'e', 0x35
        .byte '3', 0x35, ' ', 0x35
        .byte 'f', 0x35, 'r', 0x35, 'o', 0x35, 'm', 0x35, ' ', 0x35
        .byte 't', 0x35, 'a', 0x35, 's', 0x35, 'k', 0x35, '1', 0x35, '!', 0x35
        len1_3 = . - message1_3

    message2_1:
        .byte 'M', 0x14, 'e', 0x14, 's', 0x14, 'a', 0x14, 'g', 0x14, 'e', 0x14
        .byte '1', 0x14, ' ', 0x14
        .byte 'f', 0x14, 'r', 0x14, 'o', 0x14, 'm', 0x14, ' ', 0x14
        .byte 't', 0x14, 'a', 0x14, 's', 0x14, 'k', 0x14, '2', 0x14, '!', 0x14
        len2_1 = . - message2_1
    message2_2:
        .byte 'M', 0x14, 'e', 0x14, 's', 0x14, 'a', 0x14, 'g', 0x14, 'e', 0x14
        .byte '2', 0x14, ' ', 0x14
        .byte 'f', 0x14, 'r', 0x14, 'o', 0x14, 'm', 0x14, ' ', 0x14
        .byte 't', 0x14, 'a', 0x14, 's', 0x14, 'k', 0x14, '2', 0x14, '!', 0x14
        len2_2 = . - message2_2
    message2_3:
        .byte 'M', 0x14, 'e', 0x14, 's', 0x14, 'a', 0x14, 'g', 0x14, 'e', 0x14
        .byte '3', 0x14, ' ', 0x14
        .byte 'f', 0x14, 'r', 0x14, 'o', 0x14, 'm', 0x14, ' ', 0x14
        .byte 't', 0x14, 'a', 0x14, 's', 0x14, 'k', 0x14, '2', 0x14, '!', 0x14
        len2_3 = . - message2_3

    STACK:
        .space 100
    ST1 = . - STACK
        .space 100
    ST2 = . - STACK
    STACK_END:
