
.text

# Global labels:
	.global prthex
        .global prtnl

# Doubleword sizes:
	.equ d1, 8
        .equ d2, 16
        .equ d3, 24
        .equ d4, 32
        .equ d5, 40

        .equ d1n, -8
        .equ d2n, -16
        .equ d3n, -24
        .equ d4n, -32
        .equ d5n, -40

# Print a unsigned number to StdOut, in base 16.
# In:  a0 - A number.
# Ret: Nothing.
# SE:  A hexidecimal number to StdOut.
#################################################
prthex:
    # Configure stack.
    addi sp, sp, d5n		# Advance sp for stack frame.
    sd ra, 0(sp)                # Save ra.
    sd s1, d1(sp)		# Save s1.
    sd s2, d2(sp)		# Save s2.
    sd s3, d3(sp)		# Save s3.
    sd s4, d4(sp)		# Save s4.

    mv s3, a0			# Copy a0 into register, to save.

    # Print prefix
    la a0, hprefix		# Load addr of string.
    jal prtstr
    
    # Get largest power of 16, le the passed number, or 1.
    li s1, 16			# Set base.
    li s2, 1			# Init divisor.
    beqz s3, prthex_end_loop	# Check for zero.

prthex_loop:
    mul t0, s2, s1		# Get next larger divisor.
    beqz t0, prthex_end_loop	# Check for overflow.
    bgtu t0, s3, prthex_end_loop	# Check for next divisor GT a0.

    mv s2, t0			# Set next divisor.

    j prthex_loop
prthex_end_loop:		# Divisor in s2.

prthex_loop2:
    divu s4, s3, s2		# Divide passed number by divisor.
    
    li t0, 10			# Load cutoff for first letter.
    bgeu s4, t0, prthex_letr	# Jump to load letter value.
    
    addi a0, s4, '0'		# Get digit value to print.
    j prthex_print_char
    
prthex_letr:
    addi a0, s4, 'A' - 10

prthex_print_char:
    jal prtchr

    # Prepare for next cycle.
    mul t0, s4, s2		# Get value to subtract from number.
    sub s3, s3, t0		# Get rmainder for next pass.
 
    divu s2, s2, s1		# Divide divisor by base.
    bnez s2, prthex_loop2	# End loop when divisor becomes zero.

prthex_end:
    # Restore stack.
    ld s4, d4(sp)		# Restore s4.
    ld s3, d3(sp)		# Restore s3.
    ld s2, d2(sp)		# Restore s2.
    ld s1, d1(sp)		# Restore s1.
    ld ra, 0(sp)		# Restore ra.
    addi sp, sp, d5             # Restore sp.

    ret

# Print a newline.
# In:  Nothing.
# Ret: Nothing.
# SE:  Newline to StdOut.
###########################
prtnl:
    # Configure stack.
    addi sp, sp, d1n		# Advance sp for stack frame.
    sd ra, 0(sp)                # Save ra.

    addi a0, x0, 1		# StdOut
    la a1, nl			# Load addr of string
    addi a2, x0, 1		# String length
    addi a7, x0, 64		# linux write call
    ecall
    
  # Restore stack.
    ld ra, 0(sp)		# Restore ra.
    addi sp, sp, d1             # Restore sp.

    ret

# Print a character.
# In:  a0 - character value.
# Ret: Nothing.
# SE:  A character to StdOut.
###############################
prtchr:
    # Configure stack.
    addi sp, sp, d1n		# Advance sp for stack frame.
    sd ra, 0(sp)                # Save ra.

    la a1, char_addr		# Get char buffer address.
    ld a1, 0(a1)

    sb a0, 0(a1)		# Store char in buffer.

    addi a0, x0, 1		# StdOut
    addi a2, x0, 1		# String length
    addi a7, x0, 64		# linux write call
    ecall
    
  # Restore stack.
    ld ra, 0(sp)		# Restore ra.
    addi sp, sp, d1             # Restore sp.

    ret

# Print a string.
# In:  a0 - ptr to a zero delimited string.
# Ret: Nothing.
# SE:  A string to StdOut.
###########################################
prtstr:
    # Configure stack.
    addi sp, sp, d2n	# Advance sp for stack frame.
    sd ra, 0(sp)        # Save ra.
    sd s1, d1(sp)	# Save s1.

    mv s1, a0		# Save ptr to string.
    jal strlen		# String len to a0.

    # Print string.
    mv a2, a0
    addi a0, x0, 1	# StdOut
    mv a1, s1		# Load addr of string.
    addi a7, x0, 64	# Linux write.
    ecall

    # Restore stack.
    ld s1, d1(sp)	# Restore s1.
    ld ra, 0(sp)	# Restore ra.
    addi sp, sp, d2     # Restore sp.

    ret

## Return the length of a string.
## In:  a0 = ptr to string.
## Ret: a0 = length.
## SE:  Nothing.
## Note: returns on first non-printable character.
##################################################
strlen:
    mv t1, a0		# Init byte pointer
    li t2, ' '		# Init lowest character.
    li t3, '~'		# Init highest character.
    li a2, 0		# Init character counter.
    li t4, 10		# Init newline value.

# Loop to check each character.
sl_loop_next:
    lbu t0, 0(t1)		# Load a byte.

    beq t0, t4, sl_skip_check	# newline is OK.

    bltu t0, t2, sl_loop_done	# Check for low invalid chacacter.

    bgtu t0, t3, sl_loop_done 	# Check for high invalid character.

sl_skip_check:

    addi t1, t1, 1		# Point at next byte.
    
    addi a2, a2, 1		# Increment the character counter.
    j sl_loop_next

sl_loop_done:
    mv a0, a2
    ret

nl:   .ascii "\n"
hprefix: .asciz "0x"

char_addr:	.dword char

.data

char: .ascii " "			# Storage for 1 byte.
