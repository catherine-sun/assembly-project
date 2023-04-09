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
.eqv	LIM_LOWER	32
.eqv	LIM_UPPER	476

# Number of Rectangles (per Map):
.eqv	BORDER_N	4
.eqv	AREA1_N		10
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

.eqv	TIME_RESET	2000

.data
padding:	.space	36000
time_counter:	.word	TIME_RESET

# Area Maps:		Maps are composed of rectangles. If there are n rectangles, then the array is 4xn
# 			Every rectangle is saved as (x of top left corner, y of top left corner, width, height)
border:		.word	0, 0, 128, 8, 0, 120, 128, 8, 120, 8, 8, 112, 0, 8, 8, 112
area1:		.word	40, 30, 6, 90, 46, 92, 36, 6, 106, 106, 14, 14, 70, 54, 19, 5, 
			78, 28, 42, 6, 8, 19, 14, 4, 8, 48, 14, 4, 26, 72, 14, 4,
			8, 93, 14, 4, 26, 116, 14, 4
			
# Moving Platforms:	(x,y) top left corner during highest, leftmost position
#			(x, y, w, h, dir, total movement, current frame, movement speed)
area1_mobplats:	.word 	23, 14, 3, 12, VERT, 35, 0, 2,
			94, 50, 19, 4, VERT, 35, 0, 1, 
			48, 18, 19, 4, VERT, 28, 0, 1

# Player info:		player_x	player_y	player_w	player_h	player_dir
player:		.word	63, 		119, 		12,		9,		RIGHT,
#			movement_speed	jump_height	jump_span	on_plat
			1, 		16, 		3,		0,
#			is_max_left	is_max_right	is_max_up	is_max_down
			0,		0,		0,		1
.text
.globl main
main:
	li $s0, BASE_ADDRESS 		# $s0 stores the base address for display
	la $s1, player			# $s1 stores the player info

	li $v0, 32
	li $a0, SLEEP
	syscall

	# Paint game border
	li $a0, BORDER_N		# Number of rectangles to paint
	la $a1, border			# Array of rectangles to paint
	li $a2, WALL_COL		# Colour of rectangles to paint
	li $a3, SESSILE			# Type of rectanlges to paint
	jal paint_map
	
	li $a0, AREA1_N			# Number of rectangles to paint
	la $a1, area1			# Array of rectangles to paint
	jal paint_map

game_running:	
	la $t0, time_counter
	lw $t1, 0($t0)
	subi $t1, $t1, 1
	sw $t1, 0($t0) 
	bnez $t1, check_keypress
	li $t1, TIME_RESET
	sw $t1, 0($t0) 
	j paint_game

check_keypress:	
	li $t0, KEYSTROKE_EVENT
	lw $s6, 0($t0)
	bne $s6, 1, game_running
	lw $s6, 4($t0)
	
	beq $s6, 0x62, end		# Hit 'b' to end program
	beq $s6, 0x20, jump_player	# ASCII code of ' ' is 0x20
	beq $s6, 0x61, move_left	# ASCII code of 'a' is 0x61
	beq $s6, 0x64, move_right 	# ACSII code of 'd' is 0x64
	
	li $s6, 0
	li $v0, 32
	li $a0, SLEEP
	syscall
	
	j game_running


# -----------------------+= PLAYER MOVEMENT =+-----------------------
# Move player left by the number of units specified by the player's movement_speed.
move_left:
	lw $t7, MOVEMENT_SPEED($s1)
	
	# Save current position
	jal get_player_pos
	move $s4, $v0
	
	# Reset collision tracking
	sw $zero, IS_MAX_RIGHT($s1)
	sw $zero, IS_MAX_UP($s1)
	sw $zero, IS_MAX_DOWN($s1)
	
	# Check row-wise collision
	move $a0, $t7			# Expected x movement
	li $a1, LEFT			# Direction of movement
	jal collision_check

	lw $t8, PLAYER_X($s1)
	sub $t8, $t8, $v1		# player_x - actual x movement
	sw $t8, PLAYER_X($s1)		# Update player_x
	sw $v0, IS_MAX_LEFT($s1)	# Update player is_max_left

	# Erase current player position
	move $v0, $s4
	jal erase_cat
	
	# Player is now facing left
	li $t3, LEFT
	sw $t3, PLAYER_DIR($s1)
	j paint_game

# Move player right by the number of units specified by the player's movement_speed.
move_right:
	lw $t7, MOVEMENT_SPEED($s1)
	
	# Save current position
	jal get_player_pos
	move $s4, $v0
	
	# Reset collision tracking
	sw $zero, IS_MAX_RIGHT($s1)
	sw $zero, IS_MAX_UP($s1)
	sw $zero, IS_MAX_DOWN($s1)
	
	# Check row-wise collision
	move $a0, $t7			# Expected x movement
	li $a1, RIGHT			# Direction of movement
	jal collision_check

	lw $t8, PLAYER_X($s1)
	add $t8, $t8, $v1		# player_x + actual x movement
	sw $t8, PLAYER_X($s1)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right
	
	# Erase current player position
	move $v0, $s4
	jal erase_cat
	
	# Player is now facing right
	li $t3, RIGHT
	sw $t3, PLAYER_DIR($s1)
	j paint_game


# -----------------------+= PLAYER JUMPING =+------------------------
# Jump player in the direction it is facing, in a parabolic jump whose
# height peaks at the number of units specified by its jump_height.
# Precondition:	jump_height is a positive power of 2
jump_player:
	lw $s5, PLAYER_DIR($s1)
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
	
	# Save current position
	jal get_player_pos
	move $s4, $v0

jump_left:
	# If the player is not jumping left, check right
	bne $s5, LEFT, jump_right	

	# Check row-wise collision
	move $a0, $t7			# Expected x movement
	li $a1, LEFT			# Direction of movement
	jal collision_check

	lw $t8, PLAYER_X($s1)
	sub $t8, $t8, $v1		# player_x - actual x movement
	sw $t8, PLAYER_X($s1)		# Update player_x
	sw $v0, IS_MAX_LEFT($s1)	# Update player is_max_left
	
	j jump_y

jump_right:
	# If the player is not jumping left or right, jump upwards
	bne $s5, RIGHT, jump_y
	
	# Check row-wise collision
	move $a0, $t7			# Expected x movement
	li $a1, RIGHT			# Direction of movement
	jal collision_check

	lw $t8, PLAYER_X($s1)
	add $t8, $t8, $v1		# player_x + actual x movement
	sw $t8, PLAYER_X($s1)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right

jump_y:	
	# Check col-wise collision
	jal get_player_pos
	move $a0, $s6			# Expected y movement
	li $a1, UP			# Direction of movement
	jal collision_check

	lw $t9, PLAYER_Y($s1)
	sub $t9, $t9, $v1		# player_y - actual y movement
	sw $t9, PLAYER_Y($s1)		# Update player_y
	sw $v0, IS_MAX_UP($s1)		# Update player is_max_up

	# Erase old player position
	move $v0, $s4
	jal erase_cat
	
	# Paint new player position
	jal get_player_pos
	jal paint_cat

jump_next:
	li $v0, 32
	li $a0, SLEEP
	syscall
	
	sra $s6, $s6, 1			# Next jump height (divide by 2)
	bnez $s6, jump_up
	
	j paint_game


# -----------------------+= PLAYER FALLING =+------------------------
# Fall player until they collide with the ground or a platform
fall_player:
	lw $s5, PLAYER_DIR($s1)
	lw $t7, JUMP_SPAN($s1)
	
	# Player is no longer hitting ceiling
	sw $zero, IS_MAX_UP($s1)
	
	# Initial fall step has height 2
	li $s6, 2

fall_down:
	# Check if player cannot fall more down
	lw $t3, IS_MAX_DOWN($s1)
	bnez $t3, game_running
	
	# Save current position
	jal get_player_pos
	move $s4, $v0

fall_left:
	# If the player is not falling left, check right
	bne $s5, LEFT, fall_right
	
	# Check if player cannot fall more left
	lw $t3, IS_MAX_LEFT($s1)
	bnez $t3, fall_y

	# Check row-wise collision
	move $a0,, $t7			# Expected x movement
	li $a1, LEFT			# Direction of movement
	jal collision_check

	lw $t8, PLAYER_X($s1)
	sub $t8, $t8, $v1		# player_x - actual x movement
	sw $t8, PLAYER_X($s1)		# Update player_x
	sw $v0, IS_MAX_LEFT($s1)	# Update player is_max_left
	j fall_y

fall_right:
	# If the player is not falling left or right, fall downwards
	bne $s5, RIGHT, fall_y
	
	# Check if player cannot fall more right
	lw $t3, IS_MAX_RIGHT($s1)
	bnez $t3, fall_y
	
	# Check row-wise collision
	move $a0, $t7			# Expected x movement
	li $a1, RIGHT			# Direction of movement
	jal collision_check

	lw $t8, PLAYER_X($s1)
	add $t8, $t8, $v1		# player_x + actual x movement
	sw $t8, PLAYER_X($s1)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right

fall_y:	
	# Check col-wise collision
	jal get_player_pos
	move $a0, $s6			# Expected y movement
	li $a1, DOWN			# Direction of movement
	jal collision_check

	lw $t9, PLAYER_Y($s1)
	add $t9, $t9, $v1		# player_y + actual y movement
	sw $t9, PLAYER_Y($s1)		# Update player_y
	sw $v0, IS_MAX_DOWN($s1)	# Update player is_max_down

	# Erase current player position
	move $v0, $s4
	jal erase_cat
	
	# Paint new player position
	jal get_player_pos
	jal paint_cat

fall_next:	
	li $v0, 32
	li $a0, SLEEP
	syscall
	
	sll $s6, $s6, 1			# Next falling height (multiply by 2)
	bnez $s6, fall_down
	
	j paint_game

# ---------------------+= CHECKING COLLISIONS =+---------------------
# $a0 = expected movement (>0)
# $a1 = direction of movement
# $v0 = 1 or 0, if a collision occurred or not
# $v1 = actual movement
collision_check:	
	sw $zero, ON_PLAT($s1)		# Reset on a platform
	li $t0, 1			# Movement step
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
	blt $t3, 0, collision_true
	bgt $t3, 119, collision_true
	
	# Check y step w.r.t. boundaries
	blt $t4, 0, collision_true
	bgt $t4, 119, collision_true
	
	# Calculate offset
	sll $t4, $t4, 9			# $t4 = Display With in Pixels*player_y
	sll $t3, $t3, 2			# $t3 = Unit Width in Pixels*player_x
	add $t3, $t3, $t4		# offset = $t3 + $t4
	add $t4, $s0, $t3		# $t4 = base + offset
	
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
# Paint the map of area provided by...
# $a0 = number of rectangles to paint
# $a1 = array of rectangles to paint
# $a2 = colour of rectangles to paint
# $a3 = type of rectanlges to paint (act as array len)
paint_map:
	li $t1, 0
	sll $t0, $a0, 4
	beq $a3, SESSILE, paint_rectangle
	sll $t0, $a0, 5
	
paint_rectangle:
	add $t4, $a1, $t1		# Address of current rectangle
	lw $t6, OBJ_X($t4)		# rectangle_x
	lw $t7, OBJ_Y($t4)		# rectangle_y
	lw $t8, OBJ_W($t4)		# rectangle_width
	lw $t9, OBJ_H($t4)		# rectangle_height
	
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
	
	add $t1, $t1, $a3		# Get next possible rectangle (increment by array length)
	
	blt $t1, $t0, paint_rectangle	# Check if there are still rectangles to paint
	jr $ra
	
# Paint one frame of the game. This includes players, moving platforms, and other entities.
paint_game:
	# Paint the player
	jal get_player_pos
	jal paint_cat
	
	# Gravity: let player fall if it can still move down
	lw $t0, IS_MAX_DOWN($s1)
	beqz $t0, fall_player
	
platform_movement:
	la $s7, area1_mobplats
	li $s6, 0			# mobplat counter
	li $s3, 0			# on plat tracker
paint_mobplat:
	# Erase the mobile platforms of Area 1
	li $a0, 1			# Number of rectangles to paint
	move $a1, $s7			# Array of rectangles to paint
	li $a2, BG_COL			# Colour of rectangles to paint
	li $a3, MOBILE			# Type of rectanlges to paint
	jal paint_map
	
	# Check if player is still on platform
	lw $s3, ON_PLAT($s1)
	beqz $s3, compute_movement
	
	lw $t4, OBJ_X($s7)		# platform_x
	lw $t5, OBJ_W($s7)		# platform_w
	lw $t8, PLAYER_X($s1)		# player_x
	lw $t9, PLAYER_W($s1)		# player_w
	
	lw $t3, PLAYER_DIR($s1)
	
	# Player left most is not greater than platform right
	add $t6, $t4, $t5
	sub $t7, $t8, $t9
	bgt $t7, $t6, off_mobplat
	
	# Player right most is not less than platform left
	blt $t8, $t4, off_mobplat
	
	li $v0, 1
	li $a0, 7
	syscall
	
	j compute_movement

off_mobplat:
	# Player is not on this platform
	li $s3, 0
	
compute_movement:	
	lw $t1, OBJ_MOVEMENT($s7)
	lw $t2, OBJ_FRAME($s7)		# Get current frame
	lw $t3, OBJ_DIR($s7)
	lw $t4, OBJ_SPEED($s7)
	
	bge $t2, $t1, swap_dir
	bltz $t2, swap_dir
	j increment_plat

swap_dir:
	sub $t4, $zero, $t4
	sw $t4, OBJ_SPEED($s7)
	
increment_plat:
	add $t2, $t2, $t4
	sw $t2, OBJ_FRAME($s7)

	bne $t3, HORZ, vertical_movement
	lw $t8, OBJ_X($s7)
	add $t8, $t8, $t4		# Add current frame to obj_x or obj_y
	sw $t8, OBJ_X($s7)
	
	# Update player_x if its on a horizontal platform
	beqz $s3, paint_platform
	move $s4, $t4			# Save
	
	# Reset collision tracking
	sw $zero, IS_MAX_LEFT($s1)
	sw $zero, IS_MAX_RIGHT($s1)
	
	# Erase current player position
	jal get_player_pos
	jal erase_cat
	
	lw $t9, PLAYER_X($s1)
	add $t9, $t9, $s4		# Add current frame to player_x
	sw $t9, PLAYER_X($s1)
	
	# Paint new player position
	jal get_player_pos
	jal paint_cat

	j paint_platform
	
vertical_movement:
	lw $t8, OBJ_Y($s7)
	add $t8, $t8, $t4		# Add current frame to obj_x or obj_y
	sw $t8, OBJ_Y($s7)
	
	# Update player_y if its on a vertical platform
	beqz $s3, paint_platform
	move $s4, $t4			# Save
	
	# Reset collision tracking
	sw $zero, IS_MAX_LEFT($s1)
	sw $zero, IS_MAX_RIGHT($s1)
	
	# Erase current player position
	jal get_player_pos
	jal erase_cat
	
	lw $t9, PLAYER_Y($s1)
	add $t9, $t9, $s4		# Add current frame to player_y
	sw $t9, PLAYER_Y($s1)
	
	# Paint new player position
	jal get_player_pos
	jal paint_cat

	
paint_platform:
	li $a0, 1			# Number of rectangles to paint
	move $a1, $s7			# Array of rectangles to paint
	li $a2, PLAT_COL		# Colour of rectangles to paint
	li $a3, MOBILE			# Type of rectanlges to paint
	jal paint_map
	
	addi $s7, $s7, MOBILE
	addi $s6, $s6, 1
	li $t1, AREA1_MP
	blt $s6, $t1, paint_mobplat

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
	lw $t8, PLAYER_X($s1)
	lw $t9, PLAYER_Y($s1)
	sll $t9, $t9, 9			# $t9 = Display With in Pixels*player_y
	sll $t8, $t8, 2			# $t8 = Unit Width in Pixels*player_x
	add $t8, $t8, $t9		# offset = $t8 + $t9
	add $v0, $s0, $t8		# $v0 = base + offset
	jr $ra

end:
	li $v0, 10			# Terminate the program gracefully
	syscall

