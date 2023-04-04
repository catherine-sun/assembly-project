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
.eqv	WALL_COL	0x213491

# Boundaries:
.eqv	DISPLAY_W	512
.eqv	LIM_LOWER	32
.eqv	LIM_UPPER	476

# Number of Rectangles (per Map):
.eqv	BORDER_N	4
.eqv	MAP1_N		4

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
.eqv	PLAYER_W	8
.eqv	PLAYER_H	12
.eqv	DIR		16
.eqv	MOVEMENT_SPEED	20
.eqv	JUMP_HEIGHT	24
.eqv	JUMP_SPAN	28
.eqv	CAN_FLY		32
.eqv	IS_MAX_LEFT	36
.eqv	IS_MAX_RIGHT	40
.eqv	IS_MAX_UP	44
.eqv	IS_MAX_DOWN	48


.data
# Empty space to prevent game data from being overwritten due to large bitmap size
padding:	.space	36000

# Area Maps:		Maps are composed of rectangles. If there are n rectangles, then the array is 4xn
# 			Every rectangle is saved as (x of top left corner, y of top left corner, width, height)
border:		.word	0, 0, 128, 8, 0, 120, 128, 8, 120, 8, 8, 112, 0, 8, 8, 112
map1:		.word	70, 110, 20, 4, 20, 114, 20, 4, 30, 90, 30, 8, 70, 60, 30, 8
test_box:	.word	52, 111, 12, 9

# Player info:		pos_x	pos_y	player_w	player_h	dir
player:		.word	63, 	119, 	12,		9,		DOWN,
#			movement_speed	jump_height	jump_span	can_fly
			2, 		32, 		2,		0
#			is_max_left	is_max_right	is_max_up	is_max_down
			0,		0,		0,		1

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
	li $a2, WALL_COL		# Colour of rectangles to draw
	jal draw_map
	
	li $a0, MAP1_N			# Number of rectangles to draw
	la $a1, map1			# Array of rectangles to draw
	jal draw_map

draw_player:
	jal get_player_pos
	li $t3, GREEN
	sw $t3, 0($v0)
	
	jal test
	
	lw $t3, IS_MAX_DOWN($s1)
	beqz $t3, fall_player		# Let player fall if it can still move down
	
check_keypress: 
	lw $s6, 0($s7)
	bne $s6, 1, check_keypress
	lw $s6, 4($s7)
	
	beq $s6, 0x62, end		# Hit 'b' to end program
	
	lw $t3, IS_MAX_UP($s1)
	bnez $t3, skip_move_up		# Check if player cannot move more up
	beq $s6, 0x20, jump_player	# ASCII code of ' ' is 0x20
	beq $s6, 0x77, move_player 	# ACSII code of 'w' is 0x77
	
skip_move_up:
	lw $t3, IS_MAX_LEFT($s1)
	bnez $t3, skip_move_left	# Check if player cannot move more left
	beq $s6, 0x61, move_player	# ASCII code of 'a' is 0x61

skip_move_left:
	lw $t3, IS_MAX_RIGHT($s1)
	bnez $t3, skip_move_right	# Check if player cannot move more right
	beq $s6, 0x64, move_player 	# ACSII code of 'd' is 0x64

skip_move_right:
	lw $t3, IS_MAX_DOWN($s1)
	bnez $t3, skip_move_down	# Check if player cannot move more down
	beq $s6, 0x73, move_player 	# ACSII code of 's' is 0x73

skip_move_down:	
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
	move $s4, $v0
	
	# Reset collision tracking
	sw $zero, IS_MAX_LEFT($s1)
	sw $zero, IS_MAX_RIGHT($s1)
	sw $zero, IS_MAX_UP($s1)
	
	# Reset player is_max_down if flying is disabled
	lw $t3, CAN_FLY($s1)
	sw $t3, IS_MAX_DOWN($s1)

move_left:
	# If the player is not moving left, check right
	bne $s6, 0x61, move_right
	
	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, LEFT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	sub $t8, $t8, $v1		# player_x - actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_LEFT($s1)	# Update player is_max_left

	move $v0, $s4
	jal erase
	
	# Player is now facing left
	li $t3, LEFT
	sw $t3, DIR($s1)
	j draw_player

move_right:
	# If the player is not moving left or right, check up
	bne $s6, 0x64, move_up

	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, RIGHT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	add $t8, $t8, $v1		# player_x + actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right
	
	move $v0, $s4
	jal erase
	# Player is now facing right
	li $t3, RIGHT
	sw $t3, DIR($s1)
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
	lw $s5, DIR($s1)
	lw $t1, JUMP_HEIGHT($s1)
	lw $t7, JUMP_SPAN($s1)
	
	# Player is no longer on ground
	sw $zero, IS_MAX_DOWN($s1)

	# Initial jump step has height jump_height/2
	sra $s6, $t1, 1

jump_up:
	# Check if player cannot jump more up
	lw $t3, IS_MAX_UP($s1)
	bnez $t3, fall_player
	
	# Erase current player position
	jal get_player_pos
	li $t3, RED
	sw $t3, 0($v0)
	move $s4, $v0

jump_left:
	# If the player is not jumping left, check right
	bne $s5, LEFT, jump_right

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
	# If the player is not jumping left or right, jump upwards
	bne $s5, RIGHT, jump_y
	
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

	move $v0, $s4
	jal erase
	# Draw new player position
	jal get_player_pos	
	li $t3, GREEN
	sw $t3, 0($v0)
	jal test

jump_next:
	sra $s6, $s6, 1			# Next jump height (divide by 2)
	beqz $s6, draw_player
	j jump_up


# -----------------------+= PLAYER FALLING =+------------------------
# Fall player until they collide with the ground, platform, etc.
fall_player:
	lw $s5, DIR($s1)
	lw $t7, JUMP_SPAN($s1)

	# Player is no longer hitting ceiling
	sw $zero, IS_MAX_UP($s1)
	
	# Initial fall step has height 2
	li $s6, 2

fall_down:
	# Check if player cannot fall more down
	lw $t3, IS_MAX_DOWN($s1)
	bnez $t3, check_keypress
	
	# Erase current player position
	jal get_player_pos
	li $t3, RED
	sw $t3, 0($v0)
	move $s4, $v0

fall_left:
	# If the player is not falling left, check right
	bne $s5, LEFT, fall_right
	
	# Check if player cannot fall more left
	lw $t3, IS_MAX_LEFT($s1)
	bnez $t3, fall_y

	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, LEFT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	sub $t8, $t8, $v1		# player_x - actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_LEFT($s1)	# Update player is_max_left
	j fall_y

fall_right:
	# If the player is not falling left or right, fall downwards
	bne $s5, RIGHT, fall_y
	
	# Check if player cannot fall more right
	lw $t3, IS_MAX_RIGHT($s1)
	bnez $t3, fall_y
	
	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, RIGHT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	add $t8, $t8, $v1		# player_x + actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right

fall_y:	
	# Check col-wise collision
	jal get_player_pos
	move $a0, $v0			# Current position
	move $a1, $s6			# Expected y movement
	li $a2, DOWN			# Direction of movement
	jal collision_check

	lw $t9, POS_Y($s1)
	add $t9, $t9, $v1		# player_y + actual y movement
	sw $t9, POS_Y($s1)		# Update player_y
	sw $v0, IS_MAX_DOWN($s1)	# Update player is_max_down

	move $v0, $s4
	jal erase
	# Draw new player position
	jal get_player_pos	
	li $t3, GREEN
	sw $t3, 0($v0)
	jal test

fall_next:	
	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall
	
	sll $s6, $s6, 1			# Next falling height (multiply by 2)
	beqz $s6, draw_player
	j fall_down


# ---------------------+= CHECKING COLLISIONS =+---------------------
# $a1 = expected movement (>0)
# $a2 = direction of movement
collision_check:	
	li $t0, 1			# Movement step
	lw $t2, PLAYER_H($s1)		# player_h
	lw $t3, PLAYER_W($s1)		# player_w
	lw $t8, POS_X($s1)		# player_x
	lw $t9, POS_Y($s1)		# player_y
	
	li $t6, 1
	beq $a2, RIGHT, collision_outer
	
	li $t6, -1
	move $t4, $t8
	sub $t8, $t8, $t3		
	addi $t8, $t8, 1	# bottom left corner
	beq $a2, LEFT, collision_outer
	
	move $t8, $t4
	move $t4, $t9
	sub $t9, $t9, $t2		
	addi $t9, $t9, 1			# top left corner
	move $t2, $t3
	beq $a2, UP, collision_outer
	
	move $t9, $t4
	li $t6, 1
	
	
collision_outer:
	li $t1, 0			# Area of collision depends on player's height or width
	
collision_inner:
	mult $t0, $t6
	mflo $t5
	beq $a2, UP, collision_inner_y
	beq $a2, DOWN, collision_inner_y

collision_inner_x:
	# Get position to compare with boundaries
	add $t3, $t8, $t5
	sub $t4, $t9, $t1
	j do_collision_test
	
collision_inner_y:
	# Get position to compare with boundaries
	sub $t3, $t8, $t1
	add $t4, $t9, $t5

do_collision_test:
	# Check x step w.r.t. boundaries
	blt $t3, 0, collision
	bgt $t3, 119, collision
	
	# Check y step w.r.t. boundaries
	blt $t4, 0, collision
	bgt $t4, 119, collision
	
	# Calculate offset
	sll $t4, $t4, 9			# $t4 = Display With in Pixels*player_y
	sll $t3, $t3, 2			# $t3 = Unit Width in Pixels*player_x
	add $t3, $t3, $t4		# offset = $t3 + $t4
	add $t4, $s0, $t3		# $t4 = base + offset
	
	# Check colour on this step
	lw $t3, 0($t4)
	beq $t3, WALL_COL, collision
	#li $t3, 0xffc0cb
	#sw $t3, 0($t4)

	# This square is safe
	addi $t1, $t1, 1		# Next collision square
	blt $t1, $t2, collision_inner	# While this movement step hasn't been completed
	
	# The step is safe
	addi $t0, $t0, 1		# Next movement step
	ble $t0, $a1, collision_outer	# While movement < expected_movement

no_collision:
	li $v0, 0			# No collision occurred
	move $v1, $a1			# Actual movement is expected movement
	jr $ra

collision:
	li $v0, 1			# A collision occurred
	subi $t0, $t0, 1
	move $v1, $t0			# Actual movement
	jr $ra


# Check for collisions while traveling
# $a0 = current position,	$a1 = expected movement,	$a2 = direction of movement
# $v0 = 1 if a collision occurred, 0 if there was no collision,	$v1 = actual movement
collision_idk:
	# DELETE THIS WHEN THE NEW COLLISION WORKS
	li $t0, 0			# Movement step
	
	# Depending on travel direction...
	# $t1 = expected x or y movement 			DISPLAY_W*$a1 if up/down,	Unit Width in Pixels*$a1 if left/right
	# $t4 =	length of one step relative to BASE_ADDRESS 	DISPLAY_W if up/down,		Unit Width in Pixels if left/right
	# $t6 =	direction of step relative to BASE_ADDRESS 	-1 if left/up,			1 if right/down
	# $t9 = witdh/height of player to compare
	# $t8 = corresponding step in width/height
	
	sll $t1, $a1, 9
	li $t4, DISPLAY_W
	li $t6, -1
	lw $t9, PLAYER_W($s1)
	li $t8, 4
	beq $a2, UP, collision_step	# Done init for up direction
	
	li $t6, 1
	beq $a2, DOWN, collision_step	# Done init for down direction

	sll $t1, $a1, 2
	li $t4, 4
	li $t6, -1
	lw $t9, PLAYER_H($s1)
	li $t8, DISPLAY_W
	beq $a2, LEFT, collision_step	# Done init for left direction

	li $t6, 1			# Done init for right direction

collision_step:
	# Next step from current position
	add $t2, $t0, $t4
	mult $t2, $t6
	mflo $t2
	add $t2, $a0, $t2
	
	move $s6, $t2
	li $s4, 0

collision_repeat:
	li $t3, DISPLAY_W
	beq $a2, UP, collision_y
	beq $a2, DOWN, collision_y

collision_x:	
	# Get position to compare with boundaries
	div $s6, $t3
	mfhi $t3
	
	# Check step w.r.t. boundaries
	blt $t3, LIM_LOWER, collision_true
	bgt $t3, LIM_UPPER, collision_true
	
	j collision_test
	
collision_y:
	# Get position to compare with boundaries
	sub $t5, $s6, $s0
	div $t5, $t3
	mflo $t3
	sll $t3, $t3, 2
	
	# Check step w.r.t. boundaries
	blt $t3, LIM_LOWER, collision_true
	bgt $t3, LIM_UPPER, collision_true

collision_test:
	# Check colour on this step
	lw $t3, 0($s6)
	beq $t3, WALL_COL, collision_true
	li $t3, 0xffc0cb
	#sw $t3, 0($s6)
	
	sub $s6, $s6, $t8
	addi $s4, $s4, 1
	blt $s4, $t9, collision_repeat

	# The step is safe to make
	add $t0, $t0, $t4
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
	sll $t9, $t9, 9			# $t9 = Display With in Pixels*player_y
	sll $t8, $t8, 2			# $t8 = Unit Width in Pixels*player_x
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
	blt $t1, $t0, draw_rectangle	# Check if there are still rectangles to draw
	jr $ra

erase:
	#jr $ra
	li $t3, BG_COL
	li $t4, BG_COL
	li $t5, BG_COL
	j test_draw

test:
	#jr $ra
	li $t3, 0xadd07d
	li $t4, 0x5bbe74
	li $t5, 0x332935

test_draw:
	lw $t6, DIR($s1)
	beq $t6, LEFT, flipped
	beq $t6, DOWN, flipped
	sw $t3, 0($v0)
	sw $t3, -20($v0)
	sw $t3, -40($v0)
	sw $t3, -44($v0)
	
	li $t6, 0xff0000
	sw $t6, 0($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	sw $t3, -4($v0)
	sw $t3, -20($v0)
	sw $t3, -24($v0)
	sw $t3, -36($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t3, -16($v0)
	sw $t3, -20($v0)
	sw $t3, -24($v0)
	sw $t3, -32($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t3, -16($v0)
	sw $t3, -20($v0)
	sw $t3, -24($v0)
	sw $t4, -28($v0)
	sw $t3, -32($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t4, -16($v0)
	sw $t4, -20($v0)
	sw $t3, -24($v0)
	sw $t3, -28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t5, 0($v0)
	sw $t3, -4($v0)
	sw $t5, -8($v0)
	sw $t3, -12($v0)
	sw $t3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	sw $t3, -16($v0)
	
	jr $ra
	
flipped:
	sw $t3, -44($v0)
	sw $t3, -28($v0)
	sw $t3, -4($v0)
	sw $t3, 0($v0)
	
	li $t6, 0xff0000
	sw $t6, 0($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -44($v0)
	sw $t3, -40($v0)
	sw $t3, -28($v0)
	sw $t3, -24($v0)
	sw $t3, -8($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -40($v0)
	sw $t3, -36($v0)
	sw $t3, -32($v0)
	sw $t3, -28($v0)
	sw $t3, -24($v0)
	sw $t3, -20($v0)
	sw $t3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -36($v0)
	sw $t3, -32($v0)
	sw $t3, -28($v0)
	sw $t3, -24($v0)
	sw $t3, -20($v0)
	sw $t4, -16($v0)
	sw $t3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -40($v0)
	sw $t3, -36($v0)
	sw $t3, -32($v0)
	sw $t4, -28($v0)
	sw $t4, -24($v0)
	sw $t3, -20($v0)
	sw $t3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -44($v0)
	sw $t3, -40($v0)
	sw $t3, -36($v0)
	sw $t3, -32($v0)
	sw $t3, -28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t5, -44($v0)
	sw $t3, -40($v0)
	sw $t5, -36($v0)
	sw $t3, -32($v0)
	sw $t3, -28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -44($v0)
	sw $t3, -40($v0)
	sw $t3, -36($v0)
	sw $t3, -32($v0)
	sw $t3, -28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -44($v0)
	sw $t3, -28($v0)

	jr $ra

end:
	li $v0, 10			# Terminate the program gracefully
	syscall

