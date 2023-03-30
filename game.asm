#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Catherine Sun, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.eqv	BASE_ADDRESS	0x10008000
.eqv	KEYSTROKE_EVENT	0xffff0000
.eqv	LIMIT_X		127
.eqv	LIMIT_Y		127
.eqv	BG_COL		0x00000000

# Directions
.eqv	LEFT		-1
.eqv	RIGHT		1
.eqv	UP		2
.eqv	DOWN		0

# Player info array indices
.eqv	POS_X		0
.eqv	POS_Y		4
.eqv	DIR		8

# Options array indices
.eqv	MOVEMENT_SPEED	0
.eqv	JUMP_HEIGHT	4

.data
padding:	.space	36000   		# Empty space to prevent game data from being overwritten due to large bitmap size
player:	.word	63, 127, DOWN	# (player_x, player_y, direction)
options:	.word	1, 16		# (movement_speed, jump_height) 

.text
# (x, y)		player position
# (0,0)		top left corner
# (127, 0)	top right corner
# (0, 127)	bottom left corner
# (127, 127)	bottom right corner

# player jump_height is a power of 2
# DOWN means facing towards you, UP means facing away


.globl main
main:
	li $s0, BASE_ADDRESS 	# $s0 stores the base address for display	
	la $s1, player		# $s1 stores the player info
	la $s2, options		# $s2 stores the options
	li $s7,	KEYSTROKE_EVENT	# $s7 stores the address for checking if a keystroke event happened

	li $v0, 32
	li $a0, 40		# sleep 40ms
	syscall

draw_player:
	lw $t4, POS_X($s1)
	lw $t5, POS_Y($s1)

	sll $t5, $t5, 9
	sll $t4, $t4, 2
	add $t4, $t4, $t5
	add $t4, $t4, $s0
	
	li $t3, 0x00ff00 		# $t3 stores the green colour code
	sw $t3, 0($t4)
	
check_keypress: 
	lw $t6, 0($s7)
	bne $t6, 1, continue_check_keypress

	lw $t6, 4($s7)
	
	beq $t6, 0x62, end		# hit 'b' to end program
	
	beq $t6, 0x20, jump_player	# ASCII code of ' ' is 0x20
	beq $t6, 0x61, move_player	# ASCII code of 'a' is 0x61
	beq $t6, 0x64, move_player 	# ACSII code of 'd' is 0x64
	beq $t6, 0x77, move_player 	# ACSII code of 'w' is 0x77
	beq $t6, 0x73, move_player 	# ACSII code of 's' is 0x73
	
	li $t6, 0

continue_check_keypress:
	j check_keypress
	
#---------------+ PLAYER MOVEMENT +---------------#
jump_player:
	lw $t1, DIR($s1)
	lw $t7, MOVEMENT_SPEED($s2)
	lw $t6, JUMP_HEIGHT($s2)

	sra $t0, $t6, 1
	
jump_up:	
	lw $t8, POS_X($s1)
	lw $t9, POS_Y($s1)
	sll $t5, $t9, 9
	sll $t4, $t8, 2
	add $t4, $t4, $t5
	add $t4, $t4, $s0
	
	li $t3, 0xff0000 			# $t3 stores the red colour code
	sw $t3, 0($t4)			# erase current player position
	
jump_x:
	beq $t1, UP, jump_y
	add $t8, $t8, $t1
	bltz $t8, jump_y			# cannot move more left if player_x < 0
	bgt $t8, LIMIT_X, jump_y		# cannot move more right if player_x > LIMIT_X
	sw $t8, POS_X($s1)

jump_y:	
	sub $t9, $t9, $t0
	bltz $t9, fall_down		# cannot move more up if player_y < 0
	
	sw $t9, POS_Y($s1)		# update player_y
	sra $t0, $t0, 1			# next jump height (divide by 2)

	lw $t8, POS_X($s1)
	lw $t9, POS_Y($s1)
	sll $t5, $t9, 9
	sll $t4, $t8, 2
	add $t4, $t4, $t5
	add $t4, $t4, $s0
	
	li $t3, 0x00ff00 		# $t3 stores the green colour code
	sw $t3, 0($t4)			# draw new position
	
	li $v0, 32
	li $a0, 40			# sleep 40ms
	syscall
	bge $t0, 1, jump_up
	
	li $t0, 1
	li $v0, 32
	li $a0, 40			# sleep 40ms
	syscall

fall_down:	
	lw $t8, POS_X($s1)
	lw $t9, POS_Y($s1)
	sll $t5, $t9, 9
	sll $t4, $t8, 2
	add $t4, $t4, $t5
	add $t4, $t4, $s0
	
	li $t3, 0xff0000 		# $t3 stores the red colour code
	sw $t3, 0($t4)			# erase current player position
	
fall_x:
	beq $t1, UP, fall_y
	add $t8, $t8, $t1
	bltz $t8, jump_y			# cannot move more left if player_x < 0
	bgt $t8, LIMIT_X, fall_y		# cannot move more right if player_x > LIMIT_X
	sw $t8, POS_X($s1)

fall_y:	
	add $t9, $t9, $t0
	bgt $t9, LIMIT_Y, draw_player	# cannot move more down if player_y > LIMIT_Y
	
	sw $t9, POS_Y($s1)		# update player_y
	sll $t0, $t0, 1			# next falling height (multiply by 2)
	
	li $v0, 1		# print output 
	move $a0, $t0
	syscall
	
	lw $t8, POS_X($s1)
	lw $t9, POS_Y($s1)
	sll $t5, $t9, 9
	sll $t4, $t8, 2
	add $t4, $t4, $t5
	add $t4, $t4, $s0
	
	li $t3, 0x00ff00 		# $t3 stores the green colour code
	sw $t3, 0($t4)			# draw new position
	
	li $v0, 32
	li $a0, 40			# sleep 40ms
	syscall
	blt $t0, $t6 fall_down
	j draw_player

move_player:
	lw $t8, POS_X($s1)
	lw $t9, POS_Y($s1)
	lw $t7, MOVEMENT_SPEED($s2)
	
	sll $t5, $t9, 9			# $t5 = (Display Height in Pixels)*player_y
	sll $t4, $t8, 2			# $t4 = (Unit Width in Pixels)*player_x
	add $t4, $t4, $t5 		# offset = $t4 + $t5
	add $t4, $t4, $s0		# base + offset
	
	li $t3, 0xff0000 		# $t3 stores the red colour code
	sw $t3, 0($t4)			# erase current player position

move_left:	
	bne $t6, 0x61, move_right	# if the player is not moving left, check right
	
	li $t6, LEFT			# player is now facing left
	sw $t6, DIR($s1)
	
	sub $t8, $t8, $t7
	bltz $t8, draw_player		# cannot move more left if player_x < 0
	sw $t8, POS_X($s1)
	
	j draw_player

move_right:
	bne $t6, 0x64, move_up		# if the player is not moving left or right, check up	
	
	li $t6, RIGHT			# player is now facing right
	sw $t6, DIR($s1)
	
	add $t8, $t8, $t7
	bgt $t8, LIMIT_X, draw_player	# cannot move more right if player_x > LIMIT_X
	sw $t8, POS_X($s1)
	
	j draw_player
	
move_up:
	bne $t6, 0x77, move_down		# if the player is not moving left, right, or up, it must be moving down
	
	li $t6, UP			# player is now facing up
	sw $t6, DIR($s1)
	
	sub $t9, $t9, $t7
	bltz $t9, draw_player		# cannot move more up if player_y < 0
	sw $t9, POS_Y($s1)
	
	j draw_player

move_down:
	li $t6, DOWN			# player is now facing down
	sw $t6, DIR($s1)
	
	add $t9, $t9, $t7
	bgt $t9, LIMIT_Y, draw_player	# cannot move more down if player_y > LIMIT_Y
	sw $t9, POS_Y($s1)
	
	j draw_player

#-------------------------------------------------#

end:
	li $v0, 10			# terminate the program gracefully
	syscall
