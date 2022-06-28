.global main
.text

main:
    # Creates 1 space on stack and saves $ra
    subui $sp, $sp, 1
    sw $ra, 0($sp)

    # Enable IRQ2
    movsg $2, $cctrl
    andi $2, $2, 0x000F
    ori $2, $2, 0x42
    movgs $cctrl, $2

    # Save the default interrupt handler's address to memory
    movsg $2, $evec
    sw $2, old_vector($0)
    la $2, handler
    movgs $evec, $2

    # Enable the timer to generate an interrupt 100 times a second
    sw $0, 0x72003($0)
    addi $2, $0, 24
    sw $2, 0x72001($0)
    addi $2, $0, 0x3
    sw $2, 0x72000($0)

    # Jumps to serial main and links
    jal serial_main

    # Turns off global interrupts
    movgs $cctrl, $0

    # Restores $ra and removes 1 spot from stack
    lw $ra, 0($sp)
    addui $sp, $sp, 1

    jr $ra

handler:
    # Branches to label handle_irq2 if the interrupt is caused by IRQ2
    movsg $13, $estat
    andi $13, $13, 0xFFB0
    beqz $13, handle_irq2

    # If the interrupt was not caused by IRQ2, go to the default interrupt handler
    lw $13, old_vector($0)
    jr $13

handle_irq2:
    # Increases the value in counter by 1
    lw $13, counter($0)
    addi $13, $13, 1
    sw $13, counter($0)

    sw $0, 0x72003($0)
    rfe

.data
old_vector:
    .word 0