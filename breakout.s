.text
.org 0x0000
.global _start


.equ VGA,     0x08000000
.equ VGA_MAX, 0x08001DCC
.equ CYCLES_PER_MS, 5000 # Calibrated through trial and error

_start:
	movi  sp, 0x7FFC
	
GAME_LOOP:
	call ClearScreen
	
	ldw  r2, PADDLE_X(r0)
	ldw  r3, PADDLE_Y(r0)
	movi r4, 0xFF
	ldw  r5, PADDLE_WIDTH(r0)
	ldw  r6, PADDLE_HEIGHT(r0)
	call FillRect

	movi r2, 50
	call Sleep
	br GAME_LOOP

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

	movia r3, VGA	   # Get VGA buffer start
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
	
	movia r2, VGA
	movia r3, VGA_MAX
cls_loop:
	stwio r0, 0(r2)
	
	addi  r2, r2, 4
	blt   r2, r3, cls_loop

	ldw   r2, 4(sp) 
	ldw   r3, 0(sp) 
	addi  sp, sp, 8
	ret

# Sleep for a specified amount of time
# r2: Time to sleep in milliseconds
Sleep:
	subi  sp, sp, 4
	stw   r3, 0(sp) # Temp used to store conversion factor
	
	movia r3, CYCLES_PER_MS
	mul   r3, r2, r3
sleep_loop:
	subi  r3, r3, 1
	bne   r3, r0, sleep_loop
	
	ldw   r3, 0(sp)
	addi  sp, sp, 4
	ret

	
.org 0x1000
PADDLE_WIDTH: 	.word 10
PADDLE_HEIGHT:	.word 2
PADDLE_X:		.word 0
PADDLE_Y:		.word 57