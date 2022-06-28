.global main
.text

main:
    addi $5, $0, 0x4D

    # Set up the PCB for serial task
    la $1, serial_task_pcb
    # Set up the link field
    la $2, parallel_task_pcb
    sw $2, pcb_link($1)
    # Set up the previous link field
    la $2, game_task_pcb
    sw $2, pcb_prev_link($1)
    # Set up the stack pointer
    la $2, serial_task_stack
    sw $2, pcb_sp($1)
    # Set up the $ear field
    la $2, serial_main
    sw $2, pcb_ear($1)
    # Set up the $cctrl field
    sw $5, pcb_cctrl($1)
    # Set up the time slice for serial task
    addi $2, $0, 0x1
    sw $2, pcb_time_slice($1)
    # Set up the return address for serial task
    la $2, exit
    sw $2, pcb_ra($1)

    # Set up the PCB for parallel task
    la $1, parallel_task_pcb
    # Set up the link field
    la $2, game_task_pcb
    sw $2, pcb_link($1)
    # Set up the previous link field
    la $2, serial_task_pcb
    sw $2, pcb_prev_link($1)
    # Set up the stack pointer
    la $2, parallel_task_stack
    sw $2, pcb_sp($1)
    la $2, parallel_main
    sw $2, pcb_ear($1)
    # Set up the $cctrl field
    sw $5, pcb_cctrl($1)
    # Set up the time slice for parallel task
    addi $2, $0, 0x1
    sw $2, pcb_time_slice($1)
    # Set up the return address for parallel task
    la $2, exit
    sw $2, pcb_ra($1)

    # Set up the PCB for game task
    la $1, game_task_pcb
    # Set up the link field
    la $2, serial_task_pcb
    sw $2, pcb_link($1)
    # Set up the previous link field
    la $2, parallel_task_pcb
    sw $2, pcb_prev_link($1)
    # Set up the stack pointer
    la $2, game_task_stack
    sw $2, pcb_sp($1)
    # Set up the $ear field
    la $2, breakout_main
    sw $2, pcb_ear($1)
    # Set up the $cctrl field
    sw $5, pcb_cctrl($1)
    # Set up the time slice for game task
    addi $2, $0, 0x4
    sw $2, pcb_time_slice($1)
    # Set up the return address for game task
    la $2, exit
    sw $2, pcb_ra($1)

    # Set up PCB for idle task
    la $1, idle_task_pcb
    # Set up the link field
    la $2, idle_task_pcb
    sw $2, pcb_link($1)
    # Set up the stack pointer
    la $2, idle_task_stack
    sw $2, pcb_sp($1)
    # Set up the $ear field
    la $2, idle_main
    sw $2, pcb_ear($1)
    # Set up the $cctrl field
    sw $5, pcb_cctrl($1)
    # Set up the time slice for idle task
    addi $2, $0, 0x2
    sw $2, pcb_time_slice($1)

    # Set serial task as the current task
    la $1, serial_task_pcb
    sw $1, current_task($0)

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

    j load_context

handler:
    # Branches to label handle_irq2 if the interrupt is caused by IRQ2
    movsg $13, $estat
    andi $13, $13, 0xFFB0
    beqz $13, handle_irq2

    # If the interrupt was not caused by IRQ2, go to the default interrupt handler
    lw $13, old_vector($0)
    jr $13

handle_irq2:
    sw $0, 0x72003($0)

    # Increases the value in counter by 1
    lw $13, counter($0)
    addi $13, $13, 1
    sw $13, counter($0)

    # Branches to dispatcher if time slice of the current program has expired, otherwise removes one from time slice
    lw $13, time_slice($0)
    subi $13, $13, 1
    beqz $13, save_context
    sw $13, time_slice($0)

    rfe

dispatcher:
save_context:
    # Gets the PCB of the current task
    lw $13, current_task($0)

    # Saves current task's registers to PCB
    sw $1, pcb_reg1($13)
    sw $2, pcb_reg2($13)
    sw $3, pcb_reg3($13)
    sw $4, pcb_reg4($13)
    sw $5, pcb_reg5($13)
    sw $6, pcb_reg6($13)
    sw $7, pcb_reg7($13)
    sw $8, pcb_reg8($13)
    sw $9, pcb_reg9($13)
    sw $10, pcb_reg10($13)
    sw $11, pcb_reg11($13)
    sw $12, pcb_reg12($13)
    sw $sp, pcb_sp($13)
    sw $ra, pcb_ra($13)

    # Saves current task's $ers to PCB
    movsg $1, $ers
    sw $1, pcb_reg13($13)

    # Saves current task's $ear to PCB
    movsg $1, $ear
    sw $1, pcb_ear($13)

    # Saves current task's $cctrl to PCB
    movsg $1, $cctrl
    sw $1, pcb_cctrl($13)

schedule:
    # Gets the next task to begin
    lw $13, current_task($0)
    lw $13, pcb_link($13)
    sw $13, current_task($0)

    # Resets the time slice to the new task's allocated time slice
    lw $13, pcb_time_slice($13)
    sw $13, time_slice($0)

load_context:
    # Gets the PCB of the new current task
    lw $13, current_task($0)

    # Loads $ers from PCB
    lw $1, pcb_reg13($13)
    movgs $ers, $1

    # Loads $ear from PCB
    lw $1, pcb_ear($13)
    movgs $ear, $1

    # Loads #cctrl from PCB
    lw $1, pcb_cctrl($13)
    movgs $cctrl, $1

    # Loads general registers from PCB
    lw $1, pcb_reg1($13)
    lw $2, pcb_reg2($13)
    lw $3, pcb_reg3($13)
    lw $4, pcb_reg4($13)
    lw $5, pcb_reg5($13)
    lw $6, pcb_reg6($13)
    lw $7, pcb_reg7($13)
    lw $8, pcb_reg8($13)
    lw $9, pcb_reg9($13)
    lw $10, pcb_reg10($13)
    lw $11, pcb_reg11($13)
    lw $12, pcb_reg12($13)
    lw $sp, pcb_sp($13)
    lw $ra, pcb_ra($13)

    rfe

exit:
    lw $1, current_task($0)
    lw $2, pcb_link($1)
    lw $3, pcb_prev_link($1)

    # Sets the idle task as the only task in the schedule if all other tasks have exited
    seq $4, $1, $2
    bnez $4, idle_setup

    # Removes the current task from the schedule
    sw $2, pcb_link($3)
    sw $3, pcb_prev_link($2)
    
loop:
    # Loops until the exited program's time slice has finished
    j loop

idle_setup:
    # Sets the idle task as the current task
    la $1, idle_task_pcb
    sw $1, current_task($0)

    j load_context

idle_main:
    # Disables decoding on the SSD
    addi $2, $0, 0x0
    sw $2, 0x73004($0)

    # Writes '-' to all four seven segment displays
    addi $2, $0, 0x40
    sw $2, 0x73006($0)
    sw $2, 0x73007($0)
    sw $2, 0x73008($0)
    sw $2, 0x73009($0)
    j idle_main

    .equ pcb_link, 0
    .equ pcb_reg1, 1
    .equ pcb_reg2, 2
    .equ pcb_reg3, 3
    .equ pcb_reg4, 4
    .equ pcb_reg5, 5
    .equ pcb_reg6, 6
    .equ pcb_reg7, 7
    .equ pcb_reg8, 8
    .equ pcb_reg9, 9
    .equ pcb_reg10, 10
    .equ pcb_reg11, 11
    .equ pcb_reg12, 12
    .equ pcb_reg13, 13
    .equ pcb_sp, 14
    .equ pcb_ra, 15
    .equ pcb_ear, 16
    .equ pcb_cctrl, 17
    .equ pcb_time_slice, 18
    .equ pcb_prev_link, 19

.data
old_vector:
    .word 0

time_slice:
    .word 2

.bss
serial_task_pcb:
    .space 20

parallel_task_pcb:
    .space 20

game_task_pcb:
    .space 20

idle_task_pcb:
    .space 20

    .space 200
serial_task_stack:

    .space 200
parallel_task_stack:

    .space 200
game_task_stack:

idle_task_stack:
    .space 200

current_task:
    .word