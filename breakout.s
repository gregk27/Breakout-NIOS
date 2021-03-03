.text
.org 0x0000
.global _start
_start:
	movi  sp, 0x7FFC
	
	call ClearScreen
	
	
	movi r2, 5
	movi r3, 5
	movi r4, 0xAA
	movi r5, 10
	movi r6, 5
	call FillRect
	
	break

# Fill a rectangle on the screen
# r2: X position
# r3: Y position
# r4: Colour
# r5: Width
# r6: Height
FillRect:
	subi  sp, sp, 24
	stw   ra, 20(sp)
	stw   r2, 16(sp)
	stw   r3, 12(sp)
	stw   r5, 8(sp)
	stw   r6, 4(sp)
	stw   r7, 0(sp)

	add   r5, r2, r5 # Set to end x
	add   r6, r3, r6 # Set to end y
	mov   r7, r2     # Save x position

rect_vert_loop:
rect_horz_loop:
	call SetPixel
	addi  r2, r2, 1 # Increment X
	blt   r2, r5, rect_horz_loop
# END HORZ LOOP
	mov   r2, r7 # Return to initial x position
	addi  r3, r3, 1 # Increment Y
	blt   r3, r6, rect_vert_loop
# END VERT LOOP

	
	ldw   ra, 20(sp)
	ldw   r2, 16(sp)
	ldw   r3, 12(sp)
	ldw   r5, 8(sp)
	ldw   r6, 4(sp)
	ldw   r7, 0(sp)
	addi  sp, sp, 24
	ret


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