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
.eqv	SLEEP		40

# Colours:
.eqv	BG_COL		0x00000000
.eqv	WALL_COL	0x213491
.eqv	PLAT_COL	0x6d4886
.eqv	BODY_COL	0xadd07d
.eqv	SPOT_COL	0x5bbe74
.eqv	EYES_COL	0x332935

# Boundaries:
.eqv	DISPLAY_W	512
.eqv	LOWER_XLIM	0
.eqv	UPPER_XLIM	119
.eqv	LOWER_YLIM	0
.eqv	UPPER_YLIM	109

# Number of Rectangles (per Map):
.eqv	BORDER_N	4
.eqv	AREA1_N		9
.eqv	AREA1_MP	3

# Rectangle type:
.eqv	SESSILE		16
.eqv	MOBILE		32

# Moving object indices:
.eqv	OBJ_X		0
.eqv	OBJ_Y		4
.eqv	OBJ_W		8
.eqv	OBJ_H		12
.eqv	OBJ_DIR		16
.eqv	OBJ_MOVEMENT	20
.eqv	OBJ_FRAME	24
.eqv	OBJ_SPEED	28

# Directions:
.eqv	LEFT		1
.eqv	RIGHT		2
.eqv	UP		3
.eqv	DOWN		4
.eqv	VERT		5
.eqv	HORZ		6

# Player info indices:
.eqv	PLAYER_X	0
.eqv	PLAYER_Y	4
.eqv	PLAYER_W	8
.eqv	PLAYER_H	12
.eqv	PLAYER_DIR	16
.eqv	MOVEMENT_SPEED	20
.eqv	JUMP_HEIGHT	24
.eqv	JUMP_SPAN	28
.eqv	ON_PLAT		32
.eqv	IS_MAX_LEFT	36
.eqv	IS_MAX_RIGHT	40
.eqv	IS_MAX_UP	44
.eqv	IS_MAX_DOWN	48

# Player initiation
.eqv	START_X		63
.eqv	START_Y		109
.eqv	START_SPEED	1
.eqv	START_JHEIGHT	16
.eqv	START_JSPAN	3
.eqv	TRUE		1
.eqv	FALSE		0

.eqv	TIME_RESET	2000

.data
padding:	.space	36000
time_counter:	.word	TIME_RESET
newline:	.asciiz	"\n"


# Player info:		player_x	player_y	player_w	 player_h	player_dir
player:		.word	START_X,	START_Y, 	12,		9,		RIGHT,
#			movement_speed	jump_height	jump_span	on_plat		is_max_left
			START_SPEED,	START_JHEIGHT,	START_JSPAN,	FALSE,		FALSE,
#			is_max_right	is_max_up	is_max_down
			FALSE,		FALSE,		TRUE


# Area Maps:		(x of top left corner, y of top left corner, width, height) per rectangle
border:		.word	0, 0, 128, 8,
			0, 110, 128, 18,
			120, 8, 8, 102,
			0, 8, 8, 102
			
bg:		.word	8, 8, 112, 102

area1:		.word	40, 30, 6, 80,
			46, 84, 36, 6,
			106, 96, 14, 14,
			70, 54, 19, 5,
			78, 28, 42, 6,
			8, 19, 14, 4,
			8, 48, 14, 4,
			26, 72, 14, 4,
			8, 106, 14, 4

			
# Moving Platforms:	(x, y, w, h, dir, total movement, current frame, movement speed) per platform
#			(x,y) top left corner during highest, leftmost position
area1_plats:	.word 	23, 14, 3, 12, VERT, 35, 0, 2,
			52, 18, 12, 5, VERT, 28, 0, 1,
			94, 50, 19, 4, VERT, 24, 0, 1


.text
.globl main
main:
	li $v0, 32
	li $a0, SLEEP
	syscall

	# Paint game border
	li $a0, BORDER_N
	la $a1, border
	li $a2, WALL_COL
	li $a3, SESSILE
	jal paint_map
	
	# Paint game area1
	li $a0, 1
	la $a1, bg
	li $a2, BG_COL
	jal paint_map
	
	li $a0, AREA1_N
	la $a1, area1
	li $a2, WALL_COL
	jal paint_map

game_running:
	# Decrement game time counter by 1
	la $t0, time_counter
	lw $t1, 0($t0)
	subi $t1, $t1, 1
	sw $t1, 0($t0) 
	bnez $t1, check_keypress
	
	# Reset game time counter
	li $t1, TIME_RESET
	sw $t1, 0($t0)
	
	# Paint one frame
	j paint_game

check_keypress:	
	li $t0, KEYSTROKE_EVENT
	lw $t1, 0($t0)
	bne $t1, 1, game_running
	lw $t1, 4($t0)
	
	beq $t1, 0x70, game_reset	# Hit 'p' to restart
	beq $t1, 0x20, jump_player	# ASCII code of ' ' is 0x20
	beq $t1, 0x61, move_left	# ASCII code of 'a' is 0x61
	beq $t1, 0x64, move_right 	# ACSII code of 'd' is 0x64
	
	li $t1, 0
	li $v0, 32
	li $a0, SLEEP
	syscall
	
	j game_running


# -----------------------+= PLAYER MOVEMENT =+-----------------------
# Move player left by the number of units specified by the player's movement_speed.
move_left:
	# Push current position onto stack
	jal get_player_pos
	addi $sp, $sp, -4
	sw $v0, 0($sp)
	
	# Reset collision tracking
	la $t0, player
	sw $zero, IS_MAX_RIGHT($t0)
	sw $zero, IS_MAX_UP($t0)
	sw $zero, IS_MAX_DOWN($t0)
	sw $zero, ON_PLAT($t0)
	
	# Check row-wise collision
	lw $a0, MOVEMENT_SPEED($t0)	# Expected x movement
	li $a1, LEFT			# Direction of movement
	jal collision_check

	la $t0, player
	lw $t1, PLAYER_X($t0)
	sub $t1, $t1, $v1		# player_x - actual x movement
	sw $t1, PLAYER_X($t0)		# Update player_x
	sw $v0, IS_MAX_LEFT($t0)	# Update player is_max_left

	# Pop and erase current player position
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jal erase_cat
	
	# Player is now facing left
	la $t0, player
	li $t1, LEFT
	sw $t1, PLAYER_DIR($t0)
	
	j paint_game

# Move player right by the number of units specified by the player's movement_speed.
move_right:
	# Push current position onto stack
	jal get_player_pos
	addi $sp, $sp, -4
	sw $v0, 0($sp)
	
	# Reset collision tracking
	la $t0, player
	sw $zero, IS_MAX_LEFT($t0)
	sw $zero, IS_MAX_UP($t0)
	sw $zero, IS_MAX_DOWN($t0)
	sw $zero, ON_PLAT($t0)
	
	# Check row-wise collision
	lw $a0, MOVEMENT_SPEED($t0)	# Expected x movement
	li $a1, RIGHT			# Direction of movement
	jal collision_check
	
	la $t0, player
	lw $t1, PLAYER_X($t0)
	add $t1, $t1, $v1		# player_x + actual x movement
	sw $t1, PLAYER_X($t0)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right
	
	# Pop and erase current player position
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jal erase_cat
	
	# Player is now facing right
	la $t0, player
	li $t1, RIGHT
	sw $t1, PLAYER_DIR($t0)
	
	j paint_game


# -----------------------+= PLAYER JUMPING =+------------------------
# Jump player in the direction it is facing, in a parabolic jump whose
# height peaks at the number of units specified by its jump_height.
# Precondition:	jump_height is a positive power of 2
jump_player:	
	# Player is no longer on ground/platform
	la $t0, player
	sw $zero, IS_MAX_DOWN($t0)
	sw $zero, ON_PLAT($t0)

	# Initial jump step has height jump_height/2
	lw $t1, JUMP_HEIGHT($t0)
	sra $s0, $t1, 1

jump_up:
	# Check if player cannot jump more up
	la $t0, player
	lw $t0, IS_MAX_UP($t0)
	bnez $t0, fall_player
	
	# Push current position onto stack
	jal get_player_pos
	addi $sp, $sp, -4
	sw $v0, 0($sp)

jump_left:
	# If the player is not jumping left, check right
	la $t0, player
	lw $t1, PLAYER_DIR($t0)
	bne $t1, LEFT, jump_right	

	# Check row-wise collision
	lw $a0, JUMP_SPAN($t0)
	li $a1, LEFT
	jal collision_check

	la $t0, player
	lw $t1, PLAYER_X($t0)
	sub $t1, $t1, $v1		# player_x - actual x movement
	sw $t1, PLAYER_X($t0)		# Update player_x
	sw $v0, IS_MAX_LEFT($t0)	# Update player is_max_left
	
	j jump_y

jump_right:
	# If the player is not jumping left or right, jump upwards
	la $t0, player
	lw $t1, PLAYER_DIR($t0)
	bne $t1, RIGHT, jump_y
	
	# Check row-wise collision
	lw $a0, JUMP_SPAN($t0)
	li $a1, RIGHT
	jal collision_check

	la $t0, player
	lw $t1, PLAYER_X($t0)
	add $t1, $t1, $v1		# player_x + actual x movement
	sw $t1, PLAYER_X($t0)		# Update player_x
	sw $v0, IS_MAX_RIGHT($t0)	# Update player is_max_right

jump_y:	
	# Check col-wise collision
	move $a0, $s0			# Expected y movement
	li $a1, UP			# Direction of movement
	jal collision_check

	la $t0, player
	lw $t1, PLAYER_Y($t0)
	sub $t1, $t1, $v1		# player_y - actual y movement
	sw $t1, PLAYER_Y($t0)		# Update player_y
	sw $v0, IS_MAX_UP($t0)		# Update player is_max_up

	# Pop and erase current player position
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jal erase_cat
	
	# Paint new player position
	jal get_player_pos
	jal paint_cat

jump_next:
	li $v0, 32
	li $a0, SLEEP
	syscall
	
	sra $s0, $s0, 1			# Next jump height (divide by 2)
	bnez $s0, jump_up
	
	j paint_game


# -----------------------+= PLAYER FALLING =+------------------------
# Fall player until they collide with the ground or a platform
fall_player:
	# Player is no longer hitting ceiling
	la $t0, player
	sw $zero, IS_MAX_UP($t0)
	
	# Initial fall step has height 2
	li $s0, 2

fall_down:
	# Check if player cannot fall more down
	la $t0, player
	lw $t0, IS_MAX_DOWN($t0)
	bnez $t0, game_running
	
	# Push current position onto stack
	jal get_player_pos
	addi $sp, $sp, -4
	sw $v0, 0($sp)

fall_left:
	# If the player is not falling left, check right
	la $t0, player
	lw $t1, PLAYER_DIR($t0)
	bne $t1, LEFT, fall_right
	
	# Check if player cannot fall more left
	lw $t1, IS_MAX_LEFT($t0)
	bnez $t1, fall_y

	# Check row-wise collision
	lw $a0, JUMP_SPAN($t0)
	li $a1, LEFT
	jal collision_check

	la $t0, player
	lw $t1, PLAYER_X($t0)
	sub $t1, $t1, $v1		# player_x - actual x movement
	sw $t1, PLAYER_X($t0)		# Update player_x
	sw $v0, IS_MAX_LEFT($t0)	# Update player is_max_left
	
	j fall_y

fall_right:
	# If the player is not falling left or right, fall downwards
	la $t0, player
	lw $t1, PLAYER_DIR($t0)
	bne $t1, RIGHT, fall_y
	
	# Check if player cannot fall more right
	lw $t1, IS_MAX_RIGHT($t0)
	bnez $t1, fall_y
	
	# Check row-wise collision
	lw $a0, JUMP_SPAN($t0)
	li $a1, RIGHT
	jal collision_check

	la $t0, player
	lw $t1, PLAYER_X($t0)
	add $t1, $t1, $v1		# player_x + actual x movement
	sw $t1, PLAYER_X($t0)		# Update player_x
	sw $v0, IS_MAX_RIGHT($t0)	# Update player is_max_right

fall_y:	
	# Check col-wise collision
	move $a0, $s0
	li $a1, DOWN
	jal collision_check
	
	la $t0, player
	lw $t1, PLAYER_Y($t0)
	add $t1, $t1, $v1		# player_y + actual y movement
	sw $t1, PLAYER_Y($t0)		# Update player_y
	sw $v0, IS_MAX_DOWN($t0)	# Update player is_max_down

	# Pop and erase current player position
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jal erase_cat
	
	# Paint new player position
	jal get_player_pos
	jal paint_cat

fall_next:	
	li $v0, 32
	li $a0, SLEEP
	syscall
	
	sll $s0, $s0, 1			# Next falling height (multiply by 2)
	bnez $s0, fall_down
	
	j paint_game

# ---------------------+= CHECKING COLLISIONS =+---------------------
# $a0 = expected movement (>0)
# $a1 = direction of movement
# $v0 = 1 or 0, if a collision occurred or not
# $v1 = actual movement
collision_check:
	li $t0, 1			# Movement step
	la $s1, player			# $s1 stores the player info
	lw $t2, PLAYER_H($s1)		# player_h
	lw $t3, PLAYER_W($s1)		# player_w
	lw $t8, PLAYER_X($s1)		# player_x
	lw $t9, PLAYER_Y($s1)		# player_y
	
	li $t6, 1
	beq $a1, RIGHT, collision_outer
	
	li $t6, -1
	move $t4, $t8
	sub $t8, $t8, $t3		
	addi $t8, $t8, 1		# bottom left corner
	beq $a1, LEFT, collision_outer
	
	move $t8, $t4
	move $t4, $t9
	sub $t9, $t9, $t2		
	addi $t9, $t9, 1		# top left corner
	move $t2, $t3
	beq $a1, UP, collision_outer
	
	move $t9, $t4
	li $t6, 1
	
collision_outer:
	li $t1, 0			# Area of collision depends on player's height or width
	
collision_inner:
	mult $t0, $t6
	mflo $t5
	beq $a1, UP, collision_y
	beq $a1, DOWN, collision_y

collision_x:
	# Get position to compare with boundaries
	add $t3, $t8, $t5
	sub $t4, $t9, $t1
	j collision_test
	
collision_y:
	# Get position to compare with boundaries
	sub $t3, $t8, $t1
	add $t4, $t9, $t5

collision_test:
	# Check x step w.r.t. boundaries
	blt $t3, LOWER_XLIM, collision_true
	bgt $t3, UPPER_XLIM, collision_true
	
	# Check y step w.r.t. boundaries
	blt $t4, LOWER_YLIM, collision_true
	bgt $t4, UPPER_YLIM, collision_true
	
	# Calculate offset
	sll $t4, $t4, 9			# $t4 = Display With in Pixels*player_y
	sll $t3, $t3, 2			# $t3 = Unit Width in Pixels*player_x
	add $t3, $t3, $t4		# offset = $t3 + $t4
	li $t4, BASE_ADDRESS 		# $s0 stores the base address for display
	add $t4, $t4, $t3		# $t4 = base + offset
	
	# Check colour on this step
	lw $t3, 0($t4)
	beq $t3, WALL_COL, collision_true
	
	# Can only land on a platform using feet
	bne $a1, DOWN, not_falling
	beq $t3, PLAT_COL, collision_plat
	
not_falling:
	beq $t3, PLAT_COL, collision_true

	# This square is safe
	addi $t1, $t1, 1		# Next collision square
	blt $t1, $t2, collision_inner	# While this movement step hasn't been completed
	
	# The step is safe
	addi $t0, $t0, 1		# Next movement step
	ble $t0, $a0, collision_outer	# While movement < expected_movement

collision_false:
	li $v0, 0			# No collision occurred
	move $v1, $a0			# Actual movement is expected movement
	jr $ra

collision_plat:
	li $t3, 1
	la $s1, player			# $s1 stores the player info
	sw $t3, ON_PLAT($s1)		# Player is on a platform
	li $v0, 1
	li $a0, 908
	syscall
	
collision_true:
	li $v0, 1			# A collision occurred
	subi $t0, $t0, 1		# Last step that didn't cause a collision
	move $v1, $t0			# Actual movement
	jr $ra


# ---------------------+= PAINTING THE SCREEN =+---------------------
# Paint the map provided by...
# $a0 = number of rectangles to paint
# $a1 = array of rectangles to paint
# $a2 = colour of rectangles to paint
# $a3 = type of rectanlges to paint (act as array len)
paint_map:
	# Completed rectangles counter
	li $s0, 0
	
	# Total rectangles to paint
	sll $s1, $a0, 4	
	beq $a3, SESSILE, paint_rectangle
	sll $s1, $a0, 5
	
paint_rectangle:
	# Address of current rectangle ($t0)
	add $t0, $a1, $s0
	
	# Starting position relative to BASE_ADDRESS ($t1)
	lw $t1, OBJ_Y($t0)
	sll $t1, $t1, 9
	lw $t2, OBJ_X($t0)
	sll $t2, $t2, 2
	add $t1, $t2, $t1
	li $t2, BASE_ADDRESS
	add $t1, $t2, $t1
	
	# Save starting position ($s3)
	move $s3, $t1
	
	# Colouring x limit relative to BASE_ADDRESS ($t2)
	lw $t2, OBJ_W($t0)
	sll $t2, $t2, 2
	add $t2, $t1, $t2
	
	# Completed rows counter
	li $s4, 0

colour_row:
	sw $a2, 0($t1)			# Colour pixel
	addi $t1, $t1, 4		# Next square in row
	blt $t1, $t2, colour_row	# Continue colouring until x limit is reached
	
	move $t1, $s3 			# Reset x position
	addi $t1, $t1, DISPLAY_W	# Jump to next row
	addi $t2, $t2, DISPLAY_W	# Jump to next row
	move $s3, $t1			# Save x position
	
	addi $s4, $s4, 1		# Increment counter
	lw $t3, OBJ_H($t0)		# rectangle_height
	blt $s4, $t3, colour_row	# Continue until rectangle_height
	
	add $s0, $s0, $a3		# Get next possible rectangle (increment by array length)
	blt $s0, $s1, paint_rectangle	# Check if there are still rectangles to paint
	jr $ra


# Paints one frame of the game. This includes players, moving platforms, and other entities.
paint_game:
	# Paint the player
	jal get_player_pos
	jal paint_cat
	
	# Gravity: let player fall if it can still move down
	la $t0, player
	lw $t0, IS_MAX_DOWN($t0)
	beqz $t0, fall_player

paint_area:
	# Push plat counter, on_plat tracker and platforms on stack
	addi $sp, $sp, -12
	li $t0, 0
	sw $t0, 8($sp)
	sw $t0, 4($sp)
	la $t0, area1_plats
	sw $t0, 0($sp)
	
erase_plat:
	# Erase the platforms of area1
	li $a0, 1
	lw $a1,  0($sp)
	li $a2, BG_COL
	li $a3, MOBILE
	jal paint_map
	
	# Check if player is still on platform
	la $t0, player
	lw $t0, ON_PLAT($t0)
	beqz $t0, off_plat
	
on_plat_x:	
	# Player left most is not greater than platform right
	lw $t0, 0($sp)
	lw $t1, OBJ_X($t0)
	lw $t2, OBJ_W($t0)
	add $t1, $t1, $t2
	la $t0, player
	lw $t2, PLAYER_X($t0)
	lw $t3, PLAYER_W($t0)
	sub $t2, $t2, $t3
	bgt $t2, $t1, off_plat
	
	# Player right most is not less than platform left
	la $t0, player
	lw $t0, PLAYER_X($t0)
	lw $t1, 0($sp)
	lw $t1, OBJ_X($t1)
	blt $t0, $t1, off_plat
	
	# Player is on this platform
	li $t0, TRUE
	sw $t0, 4($sp)
	j move_plat

off_plat:
	# Player is not on this platform
	li $t0, FALSE
	sw $t0, 4($sp)
	
move_plat:
	lw $t0, 0($sp)
	lw $t1, OBJ_MOVEMENT($t0)
	lw $t2, OBJ_FRAME($t0)
	
	# Check if reached max movement
	bge $t2, $t1, swap_plat_dir
	bltz $t2, swap_plat_dir
	
	j plat_step

swap_plat_dir:
	# Change direction of platform movement
	lw $t1, OBJ_SPEED($t0)
	sub $t1, $zero, $t1
	sw $t1, OBJ_SPEED($t0)	
	
plat_step:
	# Update platform frame
	lw $t1, OBJ_SPEED($t0)
	add $t2, $t2, $t1
	sw $t2, OBJ_FRAME($t0)

	lw $t0, 0($sp)
	lw $t0, OBJ_DIR($t0)
	bne $t0, HORZ, plat_step_vert

plat_step_horz:
	# Update platform_x
	lw $t0, 0($sp)
	lw $t1, OBJ_X($t0)
	lw $t2, OBJ_SPEED($t0)
	add $t1, $t1, $t2
	sw $t1, OBJ_X($t0)
	
	# Update player_x if its on this platform
	lw $t0, 4($sp)
	beqz $t0, paint_plat
	
	# Reset collision tracking
	la $t0, player
	sw $zero, IS_MAX_LEFT($t0)
	sw $zero, IS_MAX_RIGHT($t0)
	
	# Erase current player position
	jal get_player_pos
	jal erase_cat
	
	# Update player_x
	lw $t0, 0($sp)
	lw $t1, OBJ_SPEED($t0)
	la $t0, player
	lw $t2, PLAYER_X($t0)
	add $t2, $t2, $t1
	sw $t2, PLAYER_X($t0)
	
	# Paint new player position
	jal get_player_pos
	jal paint_cat

	j paint_plat
	
plat_step_vert:
	# Update platform_y
	lw $t0, 0($sp)
	lw $t1, OBJ_Y($t0)
	lw $t2, OBJ_SPEED($t0)
	add $t1, $t1, $t2
	sw $t1, OBJ_Y($t0)
	
	# Update player_y if its on this platform
	lw $t0, 4($sp)
	beqz $t0, paint_plat
	
	# Reset collision tracking
	la $t0, player
	sw $zero, IS_MAX_LEFT($t0)
	sw $zero, IS_MAX_RIGHT($t0)
	
	# Erase current player position
	jal get_player_pos
	jal erase_cat
	
	# Update player_y
	lw $t0, 0($sp)
	lw $t1, OBJ_SPEED($t0)
	la $t0, player
	lw $t2, PLAYER_Y($t0)
	add $t2, $t2, $t1
	sw $t2, PLAYER_Y($t0)
	
	# Paint new player position
	jal get_player_pos
	jal paint_cat

paint_plat:
	# Paint the platforms of area 1
	li $a0, 1
	lw $a1, 0($sp)
	li $a2, PLAT_COL
	li $a3, MOBILE
	jal paint_map
	
next_plat:
	# Next platform in area1
	lw $t0, 0($sp)
	addi $t0, $t0, MOBILE
	sw $t0, 0($sp)
	
	# Check if there are still platforms to paint
	lw $t0, 8($sp)
	addi $t0, $t0, 1
	sw $t0, 8($sp)
	
	li $t1, AREA1_MP
	blt $t0, $t1, erase_plat

	# Reclaim space
	addi $sp, $sp, 12
	
	li $s6, 0
	li $v0, 32
	li $a0, SLEEP
	syscall
	
	j game_running

	
# Paint the player's cat at $v0
paint_cat:
	li $t3, BODY_COL
	li $t4, SPOT_COL
	li $t5, EYES_COL
	
	j cat_facing_right

erase_cat:
	li $t3, BG_COL
	li $t4, BG_COL
	li $t5, BG_COL

cat_facing_right:
	la $s1, player			# $s1 stores the player info
	lw $t6, PLAYER_DIR($s1)
	beq $t6, LEFT, cat_facing_left
	sw $t3, 0($v0)
	sw $t3, -20($v0)
	sw $t3, -40($v0)
	sw $t3, -44($v0)
	
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
	
cat_facing_left:
	sw $t3, -44($v0)
	sw $t3, -28($v0)
	sw $t3, -4($v0)
	sw $t3, 0($v0)
	
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
	

# ----------------------+= HELPER FUNCTIONS =+-----------------------
# Return the address of the player's current position
get_player_pos:
	la $t0, player
	lw $t1, PLAYER_X($t0)
	lw $t2, PLAYER_Y($t0)
	sll $t2, $t2, 9			# Display With in Pixels*player_y
	sll $t1, $t1, 2			# Unit Width in Pixels*player_x
	add $t1, $t1, $t2		# Offset
	li $t0, BASE_ADDRESS 		# Base address for display
	add $v0, $t0, $t1		# $v0 = base + offset
	jr $ra
	
# Reset to default values
game_reset:
	# Reset game time
	la $t0, time_counter
	li $t1, TIME_RESET
	sw $t1, 0($t0)
	
	# Reset player info
	la $t0, player
	li $t1, START_X
	sw $t1, PLAYER_X($t0)
	li $t1, START_Y
	sw $t1, PLAYER_Y($t0)
	li $t1, 12
	sw $t1, PLAYER_W($t0)
	li $t1, 9
	sw $t1, PLAYER_H($t0)
	li $t1, RIGHT
	sw $t1, PLAYER_DIR($t0)
	li $t1, START_SPEED
	sw $t1, MOVEMENT_SPEED($t0)
	li $t1, START_JHEIGHT
	sw $t1, JUMP_HEIGHT($t0)
	li $t1, START_JSPAN
	sw $t1, JUMP_SPAN($t0)
	li $t1, FALSE
	sw $t1, ON_PLAT($t0)
	sw $t1, IS_MAX_RIGHT($t0)
	sw $t1, IS_MAX_LEFT($t0)
	sw $t1, IS_MAX_UP($t0)
	li $t1, TRUE
	sw $t1, IS_MAX_DOWN($t0)
	
	j main

end:
	li $v0, 10			# Terminate the program gracefully
	syscall

