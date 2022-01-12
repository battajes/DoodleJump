#####################################################################
#
# CSC258H5S Winter 2021 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Jessica Batta, 1006250174
# - Student 2: Anil Maharajh, 1005913692
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
# We reached milestone 4
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# Music: 13
# Shooting: 10 
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
# to move left use j and to move right is k
#
#####################################################################

# Each row is 128 bytes
# 3968 is the 32 row and final row and the last digit is 4092
# The exact middle is 2112

.data
	displayAddress:	.word	0x10008000
	colours: .word 	0x0000002, 0xff0000, 0x00ff00, 0x0000ff, 0xffffff  
	# colours[0] = black, colours[1] = red, colours[2] = green, colours[3] = blue, colours[4], white background colour
	sprite: .word 3776, 3900, 3904, 3908, 4028, 4036 # pixels are ordered from top to bottom
	constants: .word 6, 15, 100, 8
	# to move a pixel up or down 128
	# top corner  4, 128, 132, 136, 256, 264
	plat: .word, 4016, 2480, 944 # they are 128*12 pixels apart
	message: .asciiz "Please enter your name!"
	
	player: .space 20
.text

main:	
	lw $t0, displayAddress	# $t0 stores the base address for display
	# Initializes arrays 
	la $s0, colours
	add $t1, $zero, $zero # Creates the offset for sprite array
	addi $t2, $zero, 6 # total number of character sprite, used as a stopping condition for loop
	la $t3, sprite # Stores the pixel positions into t3
	# t4 should be used for colour
	# t4 - $t8 can be used for incrementing
	la $t6, plat
	
	li $v0, 55 			
	la $a0, message		
	li $a1, 1		
	syscall

	
	# initailize keyboard values
	li $s1, 'j'
	li $s2, 'k'
	li $s3, 15 # The number of spaces up/down the sprite will move
	li $s4, 50 # the amount of time to sleep 
	li $s5, 8 # the number of pixels, each platforms contains
	
	add $s5, $zero, $zero # this represents if the sprite is moving up or down. O means up, 1 mean down
	la $t6, plat # hold the platform information 
	add $t7, $zero, $zero # the up and down counter 
	
	# storing words you have to use hard coded values
	# cannot use register values
	
	lw $t4, 16($s0) #sets the background colour
	jal random
	j background # print background

background:
	sw $t4, 0($t0)
	addi $t0, $t0, 4 # increments display pointer
	addi $t1, $t1, 4 # increment count
	bne $t1, 4096, background # if count is not equal to the total amount of pixels, paint more
	# resets pointers
	subi $t0, $t0, 4096
	li $t1, 0
	lw $t8, 0($t6) # t6 holds the pixel position of the sprite
	j drawPlat	

random:
	# random number generator 0 <= i <= 16 -> 0 <= 
	li $v0, 42
	li $a1, 16 
	syscall
	lw $t5, 4($t6)
	li $t7, 4 # represents the .word space, offset? you know what it is
	add $t9, $zero, $a0 #stores the random number into t9
	mult $t9, $t7 # makes the change of plat into a multiple of 4
	mflo $t7 # moves the result to $t7
	add $t5, $t5, $t7 # adds the result to the starting position of the plat
	sw $t5, 4($t6)
	add $t5, $zero, $zero # reset the value of t5 
	add $t7, $zero, $zero # resets t7 to be used for up
	jr $ra

drawPlat:
	lw $t4, 12($s0) # platform is blue

	add $t0, $t0, $t8 # moves the pointer of the display to pixel  
	sw $t4, 0($t0)	# paint over the position blue. 
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t8, $t8, 4 # increments the plat ptr
	addi $t1, $t1, 1 # loop counter ++
	bne $t1, 8, drawPlat # if $t1 < 8 create the platform 
	
	# reset the pointers
	subi $t1, $t1, 8 # loop counter ++
	addi $t5, $t5, 1 # t5 represents the current platform being created
	addi $t6, $t6, 4 # increments the plat ptr
	lw $t8, 0($t6)
	bne $t5, 3, drawPlat # if t5 < 3 make the next platform
	subi $t6, $t6, 12 # reset the plat ptr
	beq $t5, 3, upDown # all platforms have been made

# its the same as above but is used for removing plats
drawPlatWhite:
	add $t0, $t0, $t8 # moves the pointer of the display to pixel  
	sw $t4, 0($t0)	# paint over the position blue. 
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t8, $t8, 4 # increments the plat ptr
	addi $t1, $t1, 1 # loop counter ++
	bne $t1, 8, drawPlatWhite # if $t1 < 8 create the platform 
	
	# reset the pointers
	subi $t1, $t1, 8 # loop counter ++
	addi $t5, $t5, 1 # t5 represents the current platform being created
	addi $t6, $t6, 4 # increments the plat ptr
	lw $t8, 0($t6)
	
	bne $t5, 3, drawPlatWhite # if t5 < 3 make the next platform
	subi $t6, $t6, 12 # reset the plat ptr
	
	j shift # after removing plats, move to shift

# same as the og, but different jump, is not clean at all but if it works it works
drawPlatDown:
	lw $t4, 12($s0) # places white
	add $t0, $t0, $t8 # moves the pointer of the display to pixel  
	sw $t4, 0($t0)	# paint over the position blue. 
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t8, $t8, 4 # increments the plat ptr
	addi $t1, $t1, 1 # loop counter ++
	bne $t1, 8, drawPlatDown # if $t1 < 8 create the platform 
	
	# reset the pointers
	subi $t1, $t1, 8 # loop counter ++
	addi $t5, $t5, 1 # t5 represents the current platform being created
	addi $t6, $t6, 4 # increments the plat ptr
	lw $t8, 0($t6)
	
	bne $t5, 3, drawPlatDown # if t5 < 3 make the next platform
	subi $t6, $t6, 12 # reset the plat ptr
	
	j shiftF # after removing plats, move to shift	

upDown:
	beqz $s5, up
	beq $s5, 1 down 		

game:
	jal playMusic
	jal input # checks for keyboard input
	j upDown # keep looping
	
input:
	# if user presses a, shift registers t1-t6 by -4 and update screen
	# if user presses s, shift registers t1-t6 by 4 and update screen
	lui $a3, 0xffff # checks if a keystroke happened
	lw $t9, 0($a3)
	andi $t9, $t9, 1
	
	li $t5, 0 # $t5 is used to check how many plat has been painted, so reset it
	lw $t8, 0($t6) # t6 holds the pixel position of the sprite
	
	beqz $t9, drawPlat # Checks the ready bit if its 0, it is loop again
	lw $t9, 4($a3) # loads the input into $t8
		
	beq $s1, $t9, left # if input equals 'j' jump to left
	beq $s2, $t9, right # if input equals 'k' jump to right
	beq $s7, $t9, fireball # if input equal 'i' jump to fireball1
	j drawPlat
	
left:
	lw $t4, 16($s0) # holds the colour cyan
	lw $t5, 8($s0) # holds the colour green

	lw $t8, 0($t3) # t8 holds the pixel position of the sprite
	add $t0, $t0, $t8 # moves the pointer of the display to pixel  
	sw $t4, 0($t0)	# paint over the position black. 
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	subi $t8, $t8, 4 # subtract the og pos by 4
	add $t0, $t0, $t8  # moves the display pointer to the left of the last position  
	sw $t5, 0($t0)	# paint the position to the left green.
	sw $t8, 0($t3) # update sprite[i]
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t1, $t1, 1 # loop counter ++
	addi $t3, $t3, 4 # sprite pointer += 4
	bne $t1, $t2, left # t1 < 6
	subi $t1, $t1, 6 # resets the loop counter to 0 
	subi $t3, $t3, 24 # resets sprite pointer to 0
	
	# resets the input value
	addi $a3, $a3, 4
	li $a3, 0
	subi $a3, $a3, 4 # resets the pointer back to 0
	
	li $t5, 0 # $t5 is used to check how many plat has been painted, so reset it
	lw $t8, 0($t6) # t6 holds the pixel position of the sprite
	j drawPlat			
	
right:
	lw $t4, 16($s0) # holds the colour cyan
	lw $t5, 8($s0) # holds the colour green

	lw $t8, 0($t3) # t8 holds the pixel position of the sprite
	add $t0, $t0, $t8 # moves the pointer of the display to pixel  
	sw $t4, 0($t0)	# paint over the position black. 
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t8, $t8, 4 # add the og pos by 4
	add $t0, $t0, $t8  # moves the display pointer to the right of the last position  
	sw $t5, 0($t0)	# paint the position to the right green.
	sw $t8, 0($t3) # update sprite[i]
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t1, $t1, 1 # loop counter ++
	addi $t3, $t3, 4 # sprite pointer += 4
	bne $t1, $t2, right # t1 < 6
	subi $t1, $t1, 6 # resets the loop counter to 0 
	subi $t3, $t3, 24 # resets sprite pointer to 0
	li $a3, 0
	
	# resets the input value
	addi $a3, $a3, 4
	li $a3, 0
	subi $a3, $a3, 4 # resets the pointer back to 0
	
	li $t5, 0 # $t5 is used to check how many plat has been painted, so reset it
	lw $t8, 0($t6) # t6 holds the pixel position of the sprite
	j drawPlat			
	
up: # moves values of t3 up x times
	lw $t4, 16($s0) # holds the colour black
	lw $t5, 8($s0) # holds the colour green

	lw $t8, 0($t3) # t6 holds the pixel position of the sprite
	add $t0, $t0, $t8 # moves the pointer of the display to pixel  
	sw $t4, 0($t0)	# paint over the position black. 
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	subi $t8, $t8, 128 # move the pixel up by one
	add $t0, $t0, $t8  # moves the display pointer to the right of the last position  
	sw $t5, 0($t0)	# paint the position to the right green.
	sw $t8, 0($t3) # update sprite[i]
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t1, $t1, 1 # loop counter ++
	addi $t3, $t3, 4 # sprite pointer += 4
	bne $t1, $t2, up # t1 < 6
	addi $t7, $t7, 1 # increment up/counter by 1
	subi $t1, $t1, 6 # resets the loop counter to 0 
	subi $t3, $t3, 24 # resets sprite pointer to 0
	
	# sleep 
	li $v0, 32
	add $a0, $zero, $s4
	syscall
	
	beq $t7, $s3 switchUp # after x iterations of moving the pixels up, switch to moving down
	j game

down: # moves values of t3 down x time
	lw $t4, 16($s0) # holds the colour black
	lw $t5, 8($s0) # holds the colour green

	lw $t8, 0($t3) # t8 holds the pixel position of the sprite
	add $t0, $t0, $t8 # moves the pointer of the display to pixel  
	sw $t4, 0($t0)	# paint over the position black. 
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t8, $t8, 128 # move the pixel up by one
	add $t0, $t0, $t8  # moves the display pointer to the right of the last position  
	sw $t5, 0($t0)	# paint the position to the right green.
	sw $t8, 0($t3) # update sprite[i]
	sub $t0, $t0, $t8 # resets the display pointer to 0
	
	addi $t1, $t1, 1 # loop counter ++
	addi $t3, $t3, 4 # sprite pointer += 4
	bne $t1, $t2, down # t1 < 6
	addi $t7, $t7, 1 # increment up/counter by 1
	subi $t1, $t1, 6 # resets the loop counter to 0 
	subi $t3, $t3, 24 # resets sprite pointer to 0 
	
	
	# sleep 
	li $v0, 32
	add $a0, $zero, $s4
	syscall
	
	lw $t8, 16($t3) # loads in the position of the left foot 
	lw $t9, 0($t6) # loads in the position of the first platform
	bge $t8, $t9 collision # if $t9 <= $t8 if the sprite is above the platform, jump 
	
	lw $t9, 4($t6) # loads in the position of the second platform
	bge $t8, $t9 collision # if $t9 <= $t8 if the sprite is above the platform, jump 
	
	lw $t9, 8($t6) # loads in the position of the third platform
	bge $t8, $t9 scroll # if $t9 <= $t8 if the sprite is above the platform, jump 
	
	# same but we look at the right foot
	lw $t8, 20($t3) # loads in the position of the right foot 
	lw $t9, 0($t6) # loads in the position of the first platform
	bge $t8, $t9 collision # if $t9 <= $t8 if the sprite is above the platform, jump 
	
	lw $t9, 4($t6) # loads in the position of the second platform
	bge $t8, $t9 collision # if $t9 <= $t8 if the sprite is above the platform, jump 
	
	lw $t9, 8($t6) # loads in the position of the third platform
	bge $t8, $t9 scroll # if $t9 <= $t8 if the sprite is above the platform, jump 
	
	
	bge $t8, 3968, exit # if the sprite hits the last row, game over
	
	#beq $t7, $s3 switchDown # after x iterations of moving the pixels up, switch to moving down
	
	j game

playMusic:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	li $s1, 23
	div $t8, $s1
	mfhi $s0
	bne $s0, 0, endMusic
	
	li $v0, 42
	li $a0, 0
	li $a1, 7
	syscall
	
	addi $a0, $a0, 56	
	li $a1, 2500	
	li $a2, 0	
	li $a3, 13	
	li $v0, 31
	syscall
	
endMusic:
	addi $t8, $t8, 1
	
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 8
	jr $ra
	
	
jumpSound:
	li $a0, 100	
	li $a1, 1000	
	li $a2, 121	
	li $a3, 64	
	li $v0, 31
	syscall
	jr $ra

# if the sprite is one pixel above a plat, and is greater than the starting pos of the plat, check if its in between furthest point
collision: 
	addi $t9, $t9, 32 # this is the furthest point away from the start 4*8
	ble $t8, $t9, switchDown # if the sprite is in between these points, jump up
	j game #otherwise continue moving down

scroll: 
	addi $t9, $t9, 32 # this is the furthest point away from the third plat 4*8
	bgt $t8, $t9, game # if the pixel greater than the furthest point go back to game
	# if its in between scroll the screen down
	li $s7, 1 
	lw $t8, 0($t6) # t6 holds the pixel position of the sprite
	lw $t4, 16($s0) # sets the background to be white
	li $t5, 0
	j drawPlatWhite # platforms dissapear

shift:
	# shifts platforms down
	# plat 0
	lw $t9, 0($t6) # get plat 0 start pos
	addi $t9, $t9, 128 #
	sw $t9, 0($t6)
	# plat 1
	lw $t9, 4($t6)
	addi $t9, $t9, 128
	sw $t9, 4($t6)
	# plat 2
	lw $t9, 8($t6)
	addi $t9, $t9, 128
	sw $t9, 8($t6)
	addi $s7, $s7, 1 # $s7 = 2, which means drawplat will go to shiftF after it  is done
	lw $t4, 12($s0) # platform is blue
	li $t5, 0
	j drawPlatDown # plat reappear

shiftF:
	addi $s6, $s6, 1 # increment the counter
	bne $s6, 12, scroll # keep moving everything down by 1 12 times
	
	# make plat1 plat0
	lw $s6, 4($t6)
	sw $s6, 0($t6)
	
	# make plat2 plat1
	lw $s6, 8($t6)
	sw $s6, 4($t6)
	
	# make a third platform
	addi $t6, $t6, 8 # point at the third platform
	li $t5, 952 # set plat 3 back at the same row
	sw $t5, 0($t6) 
	jal random # make a new platform
	subi $t6, $t6, 8 # point at the third platform
	li $t7, 1 # sprite will move down 
	j upDown

switchUp:
	sub $t7, $t7, $s3 # resets the up/down counter to 0
	addi $s5, $s5, 1 # switches to moving the sprite down
	j game

switchDown:
	sub $t7, $t7, $s3 # resets the up/down counter to 0
	subi $s5, $s5, 1 # switches to moving the sprite up
	j game

fireball:
	lw $t4, 4($s0)
	lw $s7, 0($t3)
	subi $s7, $s7, 128
	add, $t0, $t0, $s7
	sw $t4, 0($t0)
	sub $t0, $t0, $s7
	j drawPlat 
	
exit:
	li $v0, 10 # terminate the program gracefully
	syscall
	# wh
