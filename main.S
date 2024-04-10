
.text

# Global labels:
	.global _start

# Doubleword sizes.
	.equ d1, 8

	.equ d1n, -8

_start:
        # Load the address of a big number, already stored by the compiler before program execution.
	la a0, big_num

	# Load the contents of that dword.
        ld a0, 0(a0)
        
	# Print the big number.

	# But first, load the address of the print routine, stored by the linker, before program execution.
        la t0, prthex_addr
        ld t0, 0(t0)
        jalr t0

 	# Print a new line.
        la t0, prtnl_addr
        ld t0, 0(t0)
        jalr t0

	# Load the address of an item in the .data section.

	# Load an address the linker stored before program execution.
	la a0, data_ptr
        ld a0, 0(a0)

	# Load the contents of the dmord in the .data section.
	ld a0, 0(a0)

        # Print it.
        la t0, prthex_addr
        ld t0, 0(t0)
        jalr t0

 	# Print a new line.
        la t0, prtnl_addr
        ld t0, 0(t0)
        jalr t0

	# End 
  	addi a7, x0, 93
        ecall

big_num:	.dword 0x123456789abcdef1

prthex_addr:	.dword prthex
prtnl_addr:	.dword prtnl

data_ptr:	.dword in_data

.data

in_data:	.dword 0x5678234545678912

