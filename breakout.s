.text
.org 0x0000
.global _start
_start:
	movi  sp, 0x7FFC
	
	call ClearScreen
	
	
	movi r2, 79
	movi r3, 59
	movi r4, 0xAA
	call SetPixel
	
	break

# Set a pixel on the screen
# r2: X position, 0<=r2<=89
# r3: Y position, 0<=r3<=59
# r4: Pixel color
SetPixel:
	subi  sp, sp, 8
	stw   r2, 4(sp)
	stw   r3, 0(sp)

	muli  r3, r3, 0x80 # Get Y offset
	add   r2, r2, r3   # Shift by Y offset

	ldw   r3, VGA(r0)  # Get VGA buffer start
	add   r2, r2, r3   # Shift into VGA buffer

	stbio r4, 0(r2)    # Set byte

	ldw   r2, 4(sp)
	ldw   r3, 0(sp)
	addi  sp, sp, 8
	ret

# Clear the screen to black
ClearScreen:
	subi  sp, sp, 8
	stw   r2, 4(sp) # Current pointer
	stw   r3, 0(sp) # Max address
	
	ldw   r2, VGA(r0)
	ldw   r3, VGA_MAX(r0)
LOOP:
	stwio r0, 0(r2)
	
	addi  r2, r2, 4
	blt   r2, r3, LOOP

	ldw   r2, 4(sp) 
	ldw   r3, 0(sp) 
	addi  sp, sp, 8
	ret
	
	
.org 0x1000
VGA: .word     0x08000000
VGA_MAX: .word 0x08001DCC