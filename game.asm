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

# Colours:
.eqv	RED		0xff0000
.eqv	GREEN		0x00ff00
.eqv	BG_COL		0x00000000
.eqv	BORDER_COL	0x213491

# Boundaries:
.eqv	DISPLAY_W	512
.eqv	LIM_LOWER	32
.eqv	LIM_UPPER	476

.eqv	LIM_LEFT	8		# REMOVE THESE AFTER FALL COLLISIONS
.eqv	LIM_RIGHT	119
.eqv	LIM_UP		8
.eqv	LIM_DOWN	119

# Number of Rectangles (per Map):
.eqv	BORDER_N	4
.eqv	MAP1_N		1

# Rectangle info indices:
.eqv	RECT_ARR_W	16
.eqv	RECT_X		0
.eqv	RECT_Y		4
.eqv	RECT_W		8
.eqv	RECT_H		12

# Directions:
.eqv	LEFT		-2
.eqv	RIGHT		2
.eqv	UP		1
.eqv	DOWN		0

# Player info indices:
.eqv	POS_X		0
.eqv	POS_Y		4
.eqv	DIR		8
.eqv	MOVEMENT_SPEED	12
.eqv	JUMP_HEIGHT	16
.eqv	JUMP_SPAN	20
.eqv	IS_MAX_LEFT	24
.eqv	IS_MAX_RIGHT	28
.eqv	IS_MAX_UP	32
.eqv	IS_MAX_DOWN	36
.eqv	CAN_FLY		40


.data
# Empty space to prevent game data from being overwritten due to large bitmap size
padding:	.space	36000

# Player info:		pos_x	pos_y	dir		movement_speed	jump_height	jump_span
player:		.word	63, 	119, 	DOWN,		2, 		32, 		2,
#			is_max_left	is_max_right	is_max_up	is_max_down	can_fly
			0,		0,		0,		1,		1

# Area Maps:		Maps are composed of rectangles. If there are n rectangles, then the array is 4xn
# 			Every rectangle is saved as (x of top left corner, y of top left corner, width, height)
border:		.word	0, 0, 128, 8, 0, 120, 128, 8, 120, 8, 8, 112, 0, 8, 8, 112
map1:		.word	70, 110, 20, 8


.text
.globl main
main:
	li $s0, BASE_ADDRESS 		# $s0 stores the base address for display
	la $s1, player			# $s1 stores the player info
	li $s7,	KEYSTROKE_EVENT		# $s7 stores the address for keystroke event

	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall

	li $a0, BORDER_N		# Number of rectangles to draw
	la $a1, border			# Array of rectangles to draw
	li $a2, BORDER_COL		# Colour of rectangles to draw
	jal draw_map
	
	li $a0, MAP1_N			# Number of rectangles to draw
	la $a1, map1			# Array of rectangles to draw
	jal draw_map

draw_player:
	jal get_player_pos
	li $t3, GREEN
	sw $t3, 0($v0)
	
	lw $t3, IS_MAX_DOWN($s1)
	beqz $t3, fall_player		# Let player fall if it can still move down
	
check_keypress: 
	lw $s6, 0($s7)
	bne $s6, 1, check_keypress
	lw $s6, 4($s7)
	
	beq $s6, 0x62, end		# Hit 'b' to end program
	beq $s6, 0x20, jump_player	# ASCII code of ' ' is 0x20
	beq $s6, 0x61, move_player	# ASCII code of 'a' is 0x61
	beq $s6, 0x64, move_player 	# ACSII code of 'd' is 0x64
	beq $s6, 0x77, move_player 	# ACSII code of 'w' is 0x77
	beq $s6, 0x73, move_player 	# ACSII code of 's' is 0x73
	
	li $s6, 0
	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall
	j check_keypress


# -----------------------+= PLAYER MOVEMENT =+-----------------------
# Move player in the direction of the key event, by the number of units
# specified by its movement_speed. Update the direcion the player is facing
move_player:
	lw $t7, MOVEMENT_SPEED($s1)
	
	# Erase current player position
	jal get_player_pos
	li $t3, BG_COL
	sw $t3, 0($v0)
	
	# Reset collision tracking
	sw $zero, IS_MAX_LEFT($s1)
	sw $zero, IS_MAX_RIGHT($s1)
	sw $zero, IS_MAX_UP($s1)

move_left:
	# If the player is not moving left, check right
	bne $s6, 0x61, move_right
	
	# Player is now facing left
	li $t3, LEFT
	sw $t3, DIR($s1)
	
	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, LEFT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	sub $t8, $t8, $v1		# player_x - actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_LEFT($s1)	# Update player is_max_left
	j draw_player

move_right:
	# If the player is not moving left or right, check up
	bne $s6, 0x64, move_up
	
	# Player is now facing right
	li $t3, RIGHT
	sw $t3, DIR($s1)

	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, RIGHT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	add $t8, $t8, $v1		# player_x + actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right
	j draw_player
	
move_up:
	# If the player is not moving left, right, or up, it must be moving down
	bne $s6, 0x77, move_down
	
	# Player is now facing up
	li $t3, UP
	sw $t3, DIR($s1)
	
	# Check if flying is enabled
	lw $t3, CAN_FLY($s1)
	beqz $t3, draw_player
	
	# Check col-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected y movement
	li $a2, UP			# Direction of movement
	jal collision_check
	
	lw $t9, POS_Y($s1)
	sub $t9, $t9, $v1		# player_y - actual y movement
	sw $t9, POS_Y($s1)		# Update player_y
	sw $v0, IS_MAX_UP($s1)		# Update player is_max_up
	j draw_player

move_down:
	# Player is now facing down
	li $t3, DOWN
	sw $t3, DIR($s1)
	
	# Check if flying is enabled
	lw $t3, CAN_FLY($s1)
	beqz $t3, draw_player

	# Check col-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected y movement
	li $a2, DOWN			# Direction of movement
	jal collision_check
	
	lw $t9, POS_Y($s1)
	add $t9, $t9, $v1		# player_y + actual y movement
	sw $t9, POS_Y($s1)		# Update player_y
	sw $v0, IS_MAX_DOWN($s1)	# Update player is_max_down
	j draw_player


# -----------------------+= PLAYER JUMPING =+------------------------
# Jump player in the direction it is facing, in a parabolic jump whose
# height peaks at the number of units specified by its jump_height.
# Precondition:	jump_height is a positive power of 2
jump_player:
	lw $s4, DIR($s1)
	lw $t1, JUMP_HEIGHT($s1)
	lw $t7, JUMP_SPAN($s1)
	
	# Player is no longer grounded
	sw $zero, IS_MAX_DOWN($s1)

	# Initial jump step has height jump_height/2
	sra $s6, $t1, 1

jump_up:
	lw $t3, IS_MAX_UP($s1)
	bnez $t3, fall_player		# Check if player cannot move more up
	
	# Erase current player position
	jal get_player_pos
	li $t3, RED
	sw $t3, 0($v0)

jump_left:
	bne $s4, LEFT, jump_right
	lw $t3, IS_MAX_LEFT($s1)
	bnez $t3, jump_y		# Check if player cannot move more left

	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, LEFT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	sub $t8, $t8, $v1		# player_x - actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_LEFT($s1)	# Update player is_max_left
	j jump_y

jump_right:
	bne $s4, RIGHT, jump_y
	lw $t3, IS_MAX_RIGHT($s1)
	bnez $t3, jump_y		# Check if player cannot move more right
	
	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, RIGHT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	add $t8, $t8, $v1		# player_x + actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right

jump_y:	
	# Check col-wise collision
	jal get_player_pos
	move $a0, $v0			# Current position
	move $a1, $s6			# Expected y movement
	li $a2, UP			# Direction of movement
	jal collision_check

	lw $t9, POS_Y($s1)
	sub $t9, $t9, $v1		# player_y - actual y movement
	sw $t9, POS_Y($s1)		# Update player_y
	sw $v0, IS_MAX_UP($s1)		# Update player is_max_up
	
	move $a0, $v1
	li $v0, 1
	syscall
	
	# Draw new player position
	jal get_player_pos	
	li $t3, GREEN
	sw $t3, 0($v0)

jump_next:	
	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall
	
	sra $s6, $s6, 1			# Next jump height (divide by 2)
	beqz $s6, draw_player
	j jump_up


# -----------------------+= PLAYER FALLING =+------------------------
# Fall player until they collide with the ground, platform, etc.
fall_player:
	# Initial fall step has height 1
	li $t0, 1

	sw $zero, IS_MAX_UP($s1)
fall_down:
	# Erase current player position
	jal get_player_pos
	li $t3, BG_COL
	sw $t3, 0($v0)

	beq $t1, UP, fall_y		# [FUTURE]

fall_x:
	lw $t8, POS_X($s1)
	add $t8, $t8, $t1		# player_x + units to move left/right/stay still
	blt $t8, LIM_LEFT, fall_y	# Cannot move more left if player_x < 0
	bgt $t8, LIM_RIGHT, fall_y	# Cannot move more right if player_x > LIM_RIGHT
	sw $t8, POS_X($s1)		# Update player_x

fall_y:	
	lw $t9, POS_Y($s1)
	add $t9, $t9, $t0		# player_y + height of fall step
	ble $t9, LIM_DOWN, fall_step	# Cannot move more down if player_y > LIM_DOWN
	li $t9, LIM_DOWN		# Set player_y to LIM_DOWN
	sw $t9, POS_Y($s1)		# Update player_y
	
	# Player is grounded
	li $t2, 1
	sw $t2, IS_MAX_DOWN($s1)
	j draw_player

fall_step:
	sw $t9, POS_Y($s1)		# Update player_y
	sll $t0, $t0, 1			# Next falling height (multiply by 2)
	
	# Draw new player position
	jal get_player_pos	
	li $t3, GREEN
	sw $t3, 0($v0)
	
	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall
	
	lw $t2, IS_MAX_DOWN($s1)
	beqz $t2, fall_down		# Continue fall if not grounded
	j draw_player


# ---------------------+= CHECKING COLLISIONS =+---------------------
# Check for collisions while traveling
# $a0 = current position,	$a1 = expected movement,	$a2 = direction of movement
# $v0 = 1 if a collision occurred, 0 if there was no collision,	$v1 = actual movement
collision_check:
	li $t0, 0			# Movement step
	
	# Depending on travel direction...
	# $t1 = expected x or y movement 			(DISPLAY_W)*$a1 if up/down,	(Unit Width in Pixels)*$a1 if left/right
	# $t4 =	length of one step relative to BASE_ADDRESS 	DISPLAY_W if up/down,		Unit Width in Pixels if left/right
	# $t6 =	direction of step relative to BASE_ADDRESS 	-1 if left/up,			1 if right/down
	sll $t1, $a1, 2
	li $t4, 4
	li $t6, -1
	beq $a2, LEFT, collision_step	# Done init for left direction

	sll $t1, $a1, 9
	li $t4, DISPLAY_W
	beq $a2, UP, collision_step	# Done init for up direction
	
	li $t6, 1
	beq $a2, DOWN, collision_step	# Done init for down direction

	sll $t1, $a1, 2
	li $t4, 4			# Done init for up direction

collision_step:
	# Next step from current position
	add $t2, $t0, $t4
	mult $t2, $t6
	mflo $t2
	add $t2, $a0, $t2

	li $t3, DISPLAY_W
	beq $a2, UP, collision_y
	beq $a2, DOWN, collision_y

collision_x:	
	# Get position to compare with boundaries
	div $t2, $t3
	mfhi $t3
	
	# Check step w.r.t. boundaries
	blt $t3, LIM_LOWER, collision_true
	bgt $t3, LIM_UPPER, collision_true
	
	j collision_test
	
collision_y:
	# Get position to compare with boundaries
	sub $t5, $t2, $s0
	div $t5, $t3
	mflo $t3
	sll $t3, $t3, 2
	
	# Check step w.r.t. boundaries
	blt $t3, LIM_LOWER, collision_true
	bgt $t3, LIM_UPPER, collision_true

collision_test:
	# Check colour on this step
	lw $t3, 0($t2)
	beq $t3, RED,	skip
	bne $t3, BG_COL, collision_true
	
skip:
	# The step is safe to make
	add $t0, $t0, $t4
	
	li $t3, RED
	sw $t3, 0($t2)
	blt $t0, $t1, collision_step

collision_false:
	li $v0, 0			# No collision occurred
	move $v1, $a1			# Actual movement is expected movement
	jr $ra

collision_true:
	li $v0, 1			# A collision occurred
	sra $t5, $t0, 2			# Get movement in terms of x
	beq $a2, LEFT, collision_move
	beq $a2, RIGHT, collision_move
	sra $t5, $t0, 9			# Get movement in terms of y

collision_move:
	move $v1, $t5			# Actual movement
	jr $ra
	

# ----------------------+= HELPER FUNCTIONS =+-----------------------
# Return the address of the player's current position
get_player_pos:
	lw $t8, POS_X($s1)
	lw $t9, POS_Y($s1)
	sll $t9, $t9, 9			# $t9 = (Display With in Pixels)*player_y
	sll $t8, $t8, 2			# $t8 = (Unit Width in Pixels)*player_x
	add $t8, $t8, $t9		# offset = $t8 + $t9
	add $v0, $s0, $t8		# $v0 = base + offset
	jr $ra
	
# Draw the map of area provided by...
# $a0 = number of rectangles to draw
# $a1 = array of rectangles to draw
# $a2 = colour of rectangles to draw
draw_map:
	sll $t0, $a0, 4
	li $t1, 0
	
draw_rectangle:
	add $t4, $a1, $t1		# Address of current rectangle
	lw $t6, RECT_X($t4)		# border_x
	lw $t7, RECT_Y($t4)		# border_y
	lw $t8, RECT_W($t4)		# border_width
	lw $t9, RECT_H($t4)		# border_height
	
	# Starting position relative to BASE_ADDRESS ($t4)
	sll $t7, $t7, 9
	sll $t4, $t6, 2
	add $t4, $t4, $t7
	add $t4, $s0, $t4
	
	# Save starting position
	move $t6, $t4
	
	# Colouring x limit relative to BASE_ADDRESS ($t8)
	sll $t8, $t8, 2
	add $t8, $t4, $t8
	
	# Count number of coloured rows
	li $t5, 0

colour_row:
	sw $a2, 0($t4)			# Colour pixel
	addi $t4, $t4, 4		# Next pixel in row
	blt $t4, $t8, colour_row	# Continue colouring until x limit is reached
	
	move $t4, $t6 			# Reset x position
	addi $t4, $t4, DISPLAY_W	# Jump to next row
	addi $t8, $t8, DISPLAY_W	# Jump to next row
	move $t6, $t4			# Save x position
	addi $t5, $t5, 1		# Increment counter
	blt $t5, $t9, colour_row	# Continue if $t5 < rectangle_height

	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall
	
	addi $t1, $t1, RECT_ARR_W	# Get next possible rectangle (increment by width of rectangle array)
	ble $t1, $t0, draw_rectangle	# Check if there are still rectangles to draw
	jr $ra

end:
	li $v0, 10			# Terminate the program gracefully
	syscall

