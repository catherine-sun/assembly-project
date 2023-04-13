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
# - Milestone 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Score
# 2. Win condition
# 3. Moving platforms
# 4. Different levels
# 5. Pick up effects
#
# Link to video demonstration for final submission:
# - https://youtu.be/8c4mmzQEHuo
#
# Are you OK with us sharing the video with people outside course staff?
# - no
#
# Any additional information that the TA needs to know:
# - n/a
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
.eqv	BOOST_COL	0x82d3f4
.eqv	PALEBLUE	0xc0e3f1
.eqv	STAR_COL	0xf4be82
.eqv	LIGHTGRAY	0xc8cacf
.eqv	BLURPLE		0x5d6fc7
.eqv	MUTED_BLURPLE	0x445195
.eqv	BRIGHT_RED	0xf36776
.eqv	EMPTY_COL	0x56629e
.eqv	WOOST_COL	0xf4727d
.eqv	ORANGE		0xff8357
.eqv	REVERT_COL	0x5abe74

# Boundaries:
.eqv	DISPLAY_W	512
.eqv	LOWER_XLIM	0
.eqv	UPPER_XLIM	119
.eqv	LOWER_YLIM	0
.eqv	UPPER_YLIM	109

# Number of Rectangles/Objects/Items (per Map):
.eqv	BORDER_N	4
.eqv	AREA1_N		10
.eqv	AREA1_MP	3
.eqv	AREA1_IT	5
.eqv	AREA2_N		9
.eqv	AREA2_MP	2
.eqv	AREA2_IT	6
.eqv	AREA3_N		6
.eqv	AREA3_MP	2
.eqv	AREA3_IT	7

# Array types:
.eqv	SESSILE		16
.eqv	MOBILE		32
.eqv	ITEM		16

# Moving object indices:
.eqv	OBJ_X		0
.eqv	OBJ_Y		4
.eqv	OBJ_W		8
.eqv	OBJ_H		12
.eqv	OBJ_DIR		16
.eqv	OBJ_MOVEMENT	20
.eqv	OBJ_FRAME	24
.eqv	OBJ_SPEED	28

# Item indicies:
.eqv	ITEM_TYPE	0
.eqv	ITEM_X		4
.eqv	ITEM_Y		8
.eqv	IS_CLAIMED	12

# Item Types & Info:
.eqv	BOOST		1
.eqv	BOOST_W		5
.eqv	BOOST_H		6
.eqv	STAR		2
.eqv	STAR_W		5
.eqv	STAR_H		4
.eqv	WOOST		3
.eqv	WOOST_W		9
.eqv	WOOST_H		5
.eqv	REVERT		4
.eqv	REVERT_W	6
.eqv	REVERT_H	6

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
.eqv	IS_BOOSTED	32
.eqv	IS_WOOSTED	36
.eqv	IS_MAX_LEFT	40
.eqv	IS_MAX_RIGHT	44
.eqv	IS_MAX_UP	48
.eqv	IS_MAX_DOWN	52
.eqv	ON_PLAT		56

# Player initiation
.eqv	AREA1_X		63
.eqv	AREA1_Y		109
.eqv	AREA2_X		22
.eqv	AREA2_Y		60
.eqv	AREA3_X		68
.eqv	AREA3_Y		89
.eqv	START_SPEED	1
.eqv	START_JHEIGHT	20
.eqv	START_JSPAN	3
.eqv	BOOST_SPEED	1
.eqv	BOOST_JHEIGHT	32
.eqv	BOOST_JSPAN	2
.eqv	WOOST_SPEED	1
.eqv	WOOST_JHEIGHT	16
.eqv	WOOST_JSPAN	6
.eqv	TRUE		1
.eqv	FALSE		0

.eqv	GAME_BAR_X	28
.eqv	GAME_BAR_Y	120
.eqv	SCORE_X		65
.eqv	SCORE_Y		119

.eqv	TIME_RESET	10000

.data
padding:	.space	36000
time_counter:	.word	TIME_RESET
current_area:	.word	1
star_count:	.word	0


# Player info:		player_x	player_y	player_w	 player_h	player_dir
player:		.word	AREA1_X,	AREA1_Y, 	12,		9,		RIGHT,
#			movement_speed	jump_height	jump_span	is_boosted	is_woosted
			START_SPEED,	START_JHEIGHT,	START_JSPAN,	FALSE,		FALSE,
#			is_max_left	is_max_right	is_max_up	is_max_down	on_plat
			FALSE,		FALSE,		FALSE,		TRUE,		FALSE


# Area Maps:		(x of top left corner, y of top left corner, width, height) per rectangle
border:		.word	0, 0, 128, 8,
			0, 110, 128, 18,
			120, 8, 8, 102,
			0, 8, 8, 102
			
bg:		.word	8, 8, 112, 102
		
game_bar1:	.word	8, 113, 34, 1,
			8, 123, 34, 1,
			7, 114, 1, 9,
			42, 114, 1, 9
game_bar2:	.word	8, 114, 34, 9

area1:		.word	40, 45, 6, 65,
			46, 84, 36, 6,
			106, 96, 14, 14,
			90, 28, 30, 6,
			8, 19, 14, 4,
			8, 55, 12, 4,
			27, 80, 13, 4
			8, 106, 14, 4,
			32, 42, 14, 4,
			46, 58, 30, 4
			
area2:		.word	8, 61, 23, 6,
			8, 30, 9, 6,
			63, 34, 11, 6,
			74, 40, 6, 14,
			80, 50, 16, 4,
			46, 80, 10, 12,
			54, 102, 14, 12
			110, 59, 10, 7,
			100, 66, 20, 44

area3:		.word	46, 90, 35, 6
			46, 81, 6, 9,
			75, 81, 6, 9,
			106, 95, 16, 3, 
			8, 61, 18, 49,
			46, 20, 35, 2

win:		.word	32, 48, 64, 30

win_border:	.word	32, 47, 64, 1,
			32, 78, 64, 1,
			31, 48, 1, 30,
			96, 48, 1, 30

			
# Moving Platforms:	(x, y, w, h, dir, total movement, current frame, movement speed) per platform
#			(x,y) top left corner during highest, leftmost position
area1_plats:	.word 	50, 18, 8, 3, VERT, 8, 0, 1,
			72, 29, 8, 3, VERT, 16, 0, 2,
			94, 50, 16, 4, VERT, 24, 0, 1

area2_plats:	.word	30, 30, 12, 5, HORZ, 10, 0, 1,
			84, 76, 10, 6, VERT, 18, 0, 1

area3_plats:	.word	25, 34, 14, 4, HORZ, 70, 0, 2,
			62, 58, 20, 4, HORZ, 26, 0, 1
	
		
# Item locations:	(item_type, item_x, item_y, is_claimed)
area1_items:	.word	BOOST, 16, 103, FALSE,
			STAR, 14, 17, FALSE,
			STAR, 52, 82, FALSE,
			STAR, 110, 26, FALSE,
			REVERT, 53, 56, FALSE
			
area2_items:	.word	STAR, 38, 48, FALSE,
			BOOST, 14, 27, FALSE,
			STAR, 20, 78, FALSE,
			STAR, 88, 46, FALSE,
			WOOST, 54, 78, FALSE,
			REVERT, 92, 108, FALSE

area3_items:	.word	BOOST, 115, 107, FALSE,
			STAR, 115, 93, FALSE,
			STAR, 64, 18, FALSE,
			STAR, 17, 59, FALSE,
			REVERT, 66, 32, FALSE,
			WOOST, 65, 55, FALSE,
			BOOST, 17, 49, FALSE

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
	
	# Paint game bar
	li $a0, 4
	la $a1, game_bar1
	li $a2, BLURPLE
	jal paint_map
	
	li $a0, 1
	la $a1, game_bar2
	li $a2, MUTED_BLURPLE
	jal paint_map
	
	la $t0, BASE_ADDRESS
	li $t3, LIGHTGRAY
	sw $t3, 58400($t0)
	
	li $a0, GAME_BAR_X
	li $a1, GAME_BAR_Y
	jal paint_game_bar_text

paint_bg:
	li $a0, 1
	la $a1, bg
	li $a2, BG_COL
	jal paint_map
	
	lw $t0, current_area
	beq $t0, 2, paint_area2_bg
	beq $t0, 3, paint_area3_bg

paint_area1_bg:
	li $a0, AREA1_N
	la $a1, area1
	li $a2, WALL_COL
	jal paint_map
	
	j game_running

paint_area2_bg:
	li $a0, AREA2_N
	la $a1, area2
	li $a2, WALL_COL
	jal paint_map
	
	j game_running

paint_area3_bg:
	li $a0, AREA3_N
	la $a1, area3
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
	sw $v0, IS_MAX_RIGHT($t0)	# Update player is_max_right
	
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
	# Movement step ($t0)
	li $t0, 1

	# Get collision start 	($t8, $t9)
	# Max movement step 	($t2)
	# Increment		($t6)
	la $t1, player
	lw $t2, PLAYER_H($t1)
	lw $t3, PLAYER_W($t1)
	lw $t8, PLAYER_X($t1)
	lw $t9, PLAYER_Y($t1)
	
	# (player_x, player_y) for right
	li $t6, 1
	beq $a1, RIGHT, collision_outer
	
	# (player_x - player_w + 1, player_y) for left
	li $t6, -1
	move $t4, $t8
	sub $t8, $t8, $t3		
	addi $t8, $t8, 1
	beq $a1, LEFT, collision_outer
	
	# (player_x, player_y - player_h + 1) for up
	move $t8, $t4
	move $t4, $t9
	sub $t9, $t9, $t2		
	addi $t9, $t9, 1
	move $t2, $t3
	beq $a1, UP, collision_outer
	
	# (player_x, player_y) for down
	move $t9, $t4
	li $t6, 1
	
collision_outer:
	# Collision counter ($t1 = 0, ..., $t2)
	li $t1, 0
	
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
	
	# Calculate base_address + offset ($t4)
	sll $t4, $t4, 9
	sll $t3, $t3, 2
	add $t3, $t3, $t4
	li $t4, BASE_ADDRESS
	add $t4, $t4, $t3
	
	# Check colour on this step
	lw $t3, 0($t4)
	beq $t3, STAR_COL, handle_star
	beq $t3, BOOST_COL, handle_boost
	beq $t3, WOOST_COL, handle_woost
	beq $t3, REVERT_COL, handle_revert

continue_collision:
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
	la $t4, player
	sw $t3, ON_PLAT($t4)		# Player is on a platform
	
collision_true:
	li $v0, 1			# A collision occurred
	subi $t0, $t0, 1		# Last step that didn't cause a collision
	move $v1, $t0			# Actual movement
	jr $ra
	

handle_star:
	# Checked items counter
	li $s0, 0
	
	# ($s3, $s4) = (x, y) position of the star that needs to be erased
	subi $t4, $t4, BASE_ADDRESS
	li $s3, DISPLAY_W
	div $t4, $s3
	mfhi $s3
	sra $s3, $s3, 2
	mflo $s4
	
	lw $s7, current_area
	beq $s7, 2, handle_area2_star
	beq $s7, 3, handle_area3_star
	
handle_area1_star:
	la $s1, area1_items
	li $s2, AREA1_IT
	j find_star

handle_area2_star:
	la $s1, area2_items
	li $s2, AREA2_IT
	j find_star

handle_area3_star:
	la $s1, area3_items
	li $s2, AREA3_IT

find_star:
	lw $s5, ITEM_TYPE($s1)
	bne $s5, STAR, find_star_next
	
	lw $s5, ITEM_X($s1)
	bgt $s3, $s5, find_star_next
	
	subi $s5, $s5, STAR_W
	blt $s3, $s5, find_star_next
	
	lw $s5, ITEM_Y($s1)
	bgt $s4, $s5, find_star_next
	
	subi $s5, $s5, STAR_H
	blt $s4, $s5, find_star_next
	
	li $s5, TRUE
	sw $s5, IS_CLAIMED($s1)
	
	# Calculate base_address + offset ($v0)
	lw $s3, ITEM_X($s1)
	lw $s4, ITEM_Y($s1)
	sll $s4, $s4, 9
	sll $s3, $s3, 2
	add $s3, $s3, $s4		# Offset
	li $s5, BASE_ADDRESS 		# Base address
	add $v0, $s5, $s3		# $v0 = base + offset

	li $s3, BG_COL
	sw $s3, -4($v0)
	sw $s3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, 0($v0)
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	sw $s3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -8($v0)
	
	lw $s0, star_count
	addi $s0, $s0, 1
	sw $s0, star_count
	
	j continue_collision

find_star_next:
	# Get next possible item (increment by array length)
	addi $s1, $s1, ITEM
	addi $s0, $s0, 1
	
	# Check if there are still items to look at
	blt $s0, $s2, find_star
	j continue_collision


handle_boost:
	# Checked items counter
	li $s0, 0
	
	# ($s3, $s4) = (x, y) position of the boost that needs to be erased
	subi $t4, $t4, BASE_ADDRESS
	li $s3, DISPLAY_W
	div $t4, $s3
	mfhi $s3
	sra $s3, $s3, 2
	mflo $s4
	
	lw $s7, current_area
	beq $s7, 2, handle_area2_boost
	beq $s7, 3, handle_area3_boost
	
handle_area1_boost:
	la $s1, area1_items
	li $s2, AREA1_IT
	j find_boost

handle_area2_boost:
	la $s1, area2_items
	li $s2, AREA2_IT
	j find_boost

handle_area3_boost:
	la $s1, area3_items
	li $s2, AREA3_IT

find_boost:
	lw $s5, ITEM_TYPE($s1)
	bne $s5, BOOST, find_boost_next
	
	lw $s5, ITEM_X($s1)
	bgt $s3, $s5, find_boost_next
	
	subi $s5, $s5, BOOST_W
	blt $s3, $s5, find_boost_next
	
	lw $s5, ITEM_Y($s1)
	bgt $s4, $s5, find_boost_next
	
	subi $s5, $s5, BOOST_H
	blt $s4, $s5, find_boost_next
	
	li $s5, TRUE
	sw $s5, IS_CLAIMED($s1)
	
	# Calculate base_address + offset ($v0)
	lw $s3, ITEM_X($s1)
	lw $s4, ITEM_Y($s1)
	sll $s4, $s4, 9
	sll $s3, $s3, 2
	add $s3, $s3, $s4		# Offset
	li $s5, BASE_ADDRESS 		# Base address
	add $v0, $s5, $s3		# $v0 = base + offset
	
	li $s3, BG_COL
	
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, 0($v0)
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	sw $s3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -8($v0)
	
	la $s0, player
	li $s1, FALSE
	sw $s1, IS_WOOSTED($s0)
	li $s1, TRUE
	sw $s1, IS_BOOSTED($s0)
	li $s1, BOOST_SPEED
	sw $s1, MOVEMENT_SPEED($s0)
	li $s1, BOOST_JHEIGHT
	sw $s1, JUMP_HEIGHT($s0)
	li $s1, BOOST_JSPAN
	sw $s1, JUMP_SPAN($s0)	

	j continue_collision

find_boost_next:
	# Get next possible item (increment by array length)
	addi $s1, $s1, ITEM
	addi $s0, $s0, 1
	
	# Check if there are still items to look at
	blt $s0, $s2, find_boost
	j continue_collision


handle_woost:
	# Checked items counter
	li $s0, 0
	
	# ($s3, $s4) = (x, y) position of the woost that needs to be erased
	subi $t4, $t4, BASE_ADDRESS
	li $s3, DISPLAY_W
	div $t4, $s3
	mfhi $s3
	sra $s3, $s3, 2
	mflo $s4
	
	lw $s7, current_area
	beq $s7, 2, handle_area2_woost
	beq $s7, 3, handle_area3_woost
	
handle_area1_woost:
	la $s1, area1_items
	li $s2, AREA1_IT
	j find_woost

handle_area2_woost:
	la $s1, area2_items
	li $s2, AREA2_IT
	j find_woost

handle_area3_woost:
	la $s1, area3_items
	li $s2, AREA3_IT

find_woost:
	lw $s5, ITEM_TYPE($s1)
	bne $s5, WOOST, find_woost_next
	
	lw $s5, ITEM_X($s1)
	bgt $s3, $s5, find_woost_next

	subi $s5, $s5, WOOST_W
	blt $s3, $s5, find_woost_next
	
	lw $s5, ITEM_Y($s1)
	bgt $s4, $s5, find_woost_next
	
	subi $s5, $s5, WOOST_H
	blt $s4, $s5, find_woost_next
	
	li $s5, TRUE
	sw $s5, IS_CLAIMED($s1)
	
	# Calculate base_address + offset ($v0)
	lw $s3, ITEM_X($s1)
	lw $s4, ITEM_Y($s1)
	sll $s4, $s4, 9
	sll $s3, $s3, 2
	add $s3, $s3, $s4		# Offset
	li $s5, BASE_ADDRESS 		# Base address
	add $v0, $s5, $s3		# $v0 = base + offset
	
	li $s3, BG_COL
	
	sw $s3, -8($v0)
	sw $s3, -24($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	sw $s3, -16($v0)
	sw $s3, -20($v0)
	sw $s3, -24($v0)
	sw $s3, -28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, 0($v0)
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	sw $s3, -16($v0)
	sw $s3, -20($v0)
	sw $s3, -24($v0)
	sw $s3, -28($v0)
	sw $s3, -32($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -4($v0)
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	sw $s3, -16($v0)
	sw $s3, -20($v0)
	sw $s3, -24($v0)
	sw $s3, -28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -8($v0)
	sw $s3, -24($v0)
	
	la $s0, player
	li $s1, FALSE
	sw $s1, IS_BOOSTED($s0)
	li $s1, TRUE
	sw $s1, IS_WOOSTED($s0)
	li $s1, WOOST_SPEED
	sw $s1, MOVEMENT_SPEED($s0)
	li $s1, WOOST_JHEIGHT
	sw $s1, JUMP_HEIGHT($s0)
	li $s1, WOOST_JSPAN
	sw $s1, JUMP_SPAN($s0)	

	j continue_collision

find_woost_next:
	# Get next possible item (increment by array length)
	addi $s1, $s1, ITEM
	addi $s0, $s0, 1
	
	# Check if there are still items to look at
	blt $s0, $s2, find_woost
	j continue_collision
	
	

handle_revert:
	# Checked items counter
	li $s0, 0
	
	# ($s3, $s4) = (x, y) position of the star that needs to be erased
	subi $t4, $t4, BASE_ADDRESS
	li $s3, DISPLAY_W
	div $t4, $s3
	mfhi $s3
	sra $s3, $s3, 2
	mflo $s4
	
	lw $s7, current_area
	beq $s7, 2, handle_area2_revert
	beq $s7, 3, handle_area3_revert
	
handle_area1_revert:
	la $s1, area1_items
	li $s2, AREA1_IT
	j find_revert

handle_area2_revert:
	la $s1, area2_items
	li $s2, AREA2_IT
	j find_revert

handle_area3_revert:
	la $s1, area3_items
	li $s2, AREA3_IT

find_revert:
	lw $s5, ITEM_TYPE($s1)
	bne $s5, REVERT, find_revert_next
	
	lw $s5, ITEM_X($s1)
	bgt $s3, $s5, find_revert_next
	
	subi $s5, $s5, REVERT_W
	blt $s3, $s5, find_revert_next
	
	lw $s5, ITEM_Y($s1)
	bgt $s4, $s5, find_revert_next
	
	subi $s5, $s5, REVERT_H
	blt $s4, $s5, find_revert_next
	
	li $s5, TRUE
	sw $s5, IS_CLAIMED($s1)
	
	# Calculate base_address + offset ($v0)
	lw $s3, ITEM_X($s1)
	lw $s4, ITEM_Y($s1)
	sll $s4, $s4, 9
	sll $s3, $s3, 2
	add $s3, $s3, $s4		# Offset
	li $s5, BASE_ADDRESS 		# Base address
	add $v0, $s5, $s3		# $v0 = base + offset

	li $s3, BG_COL
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -4($v0)
	sw $s3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, 0($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, 0($v0)
	sw $s3, -12($v0)
	sw $s3, -16($v0)
	sw $s3, -20($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -4($v0)
	sw $s3, -16($v0)
	sw $s3, -20($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $s3, -8($v0)
	sw $s3, -12($v0)
	sw $s3, -20($v0)
	
	la $s0, player
	li $s3, FALSE
	sw $s3, IS_BOOSTED($s0)
	sw $s3, IS_WOOSTED($s0)
	li $s3, START_SPEED
	sw $s3, MOVEMENT_SPEED($s0)
	li $s3, START_JHEIGHT
	sw $s3, JUMP_HEIGHT($s0)
	li $s3, START_JSPAN
	sw $s3, JUMP_SPAN($s0)	
	
	j continue_collision

find_revert_next:
	# Get next possible item (increment by array length)
	addi $s1, $s1, ITEM
	addi $s0, $s0, 1
	
	# Check if there are still items to look at
	blt $s0, $s2, find_revert
	j continue_collision


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
	# Gravity: let player fall if it can still move down
	la $t0, player
	lw $t0, IS_MAX_DOWN($t0)
	beqz $t0, fall_player

paint_area:
	li $a0, GAME_BAR_X
	li $a1, GAME_BAR_Y
	lw $a2, current_area
	jal paint_game_bar_num
	
	li $a0, SCORE_X
	li $a1, SCORE_Y
	jal paint_score
	
	# Paint area items
	jal paint_items
	
	# Push plat counter, on_plat tracker
	addi $sp, $sp, -12
	li $t0, 0
	sw $t0, 8($sp)
	sw $t0, 4($sp)
	
	# Push platforms onto stack
	lw $t0, current_area
	beq $t0, 2, paint_area2_plats
	beq $t0, 3, paint_area3_plats

paint_area1_plats:
	la $t0, area1_plats
	sw $t0, 0($sp)
	j erase_plat

paint_area2_plats:
	la $t0, area2_plats
	sw $t0, 0($sp)
	j erase_plat

paint_area3_plats:
	la $t0, area3_plats
	sw $t0, 0($sp)
	
erase_plat:
	# Erase the platforms
	li $a0, 1
	lw $a1,  0($sp)
	li $a2, BG_COL
	li $a3, MOBILE
	jal paint_map
	
	# Check if player is still on platform
	la $t0, player
	lw $t0, ON_PLAT($t0)
	beqz $t0, off_plat
	
	lw $t0, 0($sp)
	lw $t0, OBJ_DIR($t0)
	beq $t0, HORZ, on_plat_y
	
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
	
on_plat_y:
	# player_y is right on top of platform
	lw $t0, 0($sp)
	lw $t1, OBJ_Y($t0)
	subi $t1, $t1, 1
	la $t0, player
	lw $t2, PLAYER_Y($t0)
	bne $t2, $t1, off_plat
	
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
	# Paint the platforms
	li $a0, 1
	lw $a1, 0($sp)
	li $a2, PLAT_COL
	li $a3, MOBILE
	jal paint_map
	
next_plat:
	# Next platform in area
	lw $t0, 0($sp)
	addi $t0, $t0, MOBILE
	sw $t0, 0($sp)
	
	# Check if there are still platforms to paint
	lw $t0, 8($sp)
	addi $t0, $t0, 1
	sw $t0, 8($sp)
	
	lw $t3, current_area
	beq $t3, 2, check_area2_plats
	beq $t3, 3, check_area3_plats

check_area1_plats:
	li $t1, AREA1_MP
	j complete_check

check_area2_plats:
	li $t1, AREA2_MP
	j complete_check

check_area3_plats:
	li $t1, AREA3_MP

complete_check:
	blt $t0, $t1, erase_plat

	# Reclaim space
	addi $sp, $sp, 12
	
	li $s6, 0
	li $v0, 32
	li $a0, SLEEP
	syscall
	
	# Paint the player
	jal get_player_pos
	jal paint_cat
	
	# Check for win
	lw $t0, star_count
	beq $t0, 3, next_area
	
	j game_running

	
# Paint the player's cat at $v0
paint_cat:
	la $t0, player
	lw $t1, IS_BOOSTED($t0)
	beq $t1, TRUE, boost_cat
	lw $t1, IS_WOOSTED($t0)
	beq $t1, TRUE, woost_cat

	li $t3, BODY_COL
	li $t4, SPOT_COL
	li $t5, EYES_COL
	
	j cat_facing_right

boost_cat:
	li $t3, BOOST_COL
	li $t4, PALEBLUE
	li $t5, EYES_COL

	j cat_facing_right

woost_cat:
	li $t3, WOOST_COL
	li $t4, ORANGE
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
	

paint_items:
	# Completed items counter
	li $s0, 0
	li $s1, 0

paint_step:
	lw $t7, current_area
	beq $t7, 2, paint_area2_items
	beq $t7, 3, paint_area3_items
	
paint_area1_items:
	la $t0, area1_items
	li $s2, AREA1_IT
	j paint_item

paint_area2_items:
	la $t0, area2_items
	li $s2, AREA2_IT
	j paint_item

paint_area3_items:
	la $t0, area3_items
	li $s2, AREA3_IT

paint_item:
	# Address of current item ($t0)
	add $t0, $t0, $s0
	
	# Calculate base_address + offset ($v0)
	lw $t1, ITEM_X($t0)
	lw $t2, ITEM_Y($t0)
	sll $t2, $t2, 9
	sll $t1, $t1, 2
	add $t1, $t1, $t2		# Offset
	li $t2, BASE_ADDRESS 		# Base address
	add $v0, $t2, $t1		# $v0 = base + offset
	
	lw $t1, ITEM_TYPE($t0)
	beq $t1, STAR, paint_star
	beq $t1, WOOST, paint_woost
	beq $t1, REVERT, paint_revert
	
paint_boost:
	# Check if boost is_claimed
	lw $t1, IS_CLAIMED($t0)
	beq $t1, TRUE, item_next
	
	li $t3, BOOST_COL
	li $t4, PALEBLUE
	
	sw $t3, -4($v0)
	sw $t4, -8($v0)
	sw $t4, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t4, -8($v0)
	sw $t3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t4, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t4, -12($v0)
	sw $t3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -8($v0)
	
	j item_next
	
paint_star:
	# Skip if star is_claimed
	lw $t1, IS_CLAIMED($t0)
	beq $t1, TRUE, item_next
	
	li $t3, STAR_COL
	
	sw $t3, -4($v0)
	sw $t3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -8($v0)
	
	j item_next
	
paint_woost:
	# Skip if woost is_claimed
	lw $t1, IS_CLAIMED($t0)
	beq $t1, TRUE, item_next
	
	li $t3, WOOST_COL
	li $t4, ORANGE
	
	sw $t3, -8($v0)
	sw $t3, -24($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t4, -8($v0)
	sw $t4, -12($v0)
	sw $t3, -16($v0)
	sw $t3, -20($v0)
	sw $t3, -24($v0)
	sw $t3, -28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t4, 0($v0)
	sw $t3, -4($v0)
	sw $t4, -8($v0)
	sw $t4, -12($v0)
	sw $t4, -16($v0)
	sw $t3, -20($v0)
	sw $t3, -24($v0)
	sw $t3, -28($v0)
	sw $t3, -32($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t4, -16($v0)
	sw $t4, -20($v0)
	sw $t4, -24($v0)
	sw $t3, -28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -8($v0)
	sw $t3, -24($v0)

	j item_next
	
paint_revert:
	# Skip if revert is_claimed
	lw $t1, IS_CLAIMED($t0)
	beq $t1, TRUE, item_next
	
	li $t3, REVERT_COL
	
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t3, -16($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	sw $t3, -12($v0)
	sw $t3, -16($v0)
	sw $t3, -20($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t3, -16($v0)
	sw $t3, -20($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t3, -20($v0)
	
item_next:
	# Get next possible item (increment by array length)
	addi $s0, $s0, ITEM
	addi $s1, $s1, 1
	
	#Check if there are still items to paint
	blt $s1, $s2, paint_step
	jr $ra


# ($a0, $a1) = (x, y) of bottom right corner of "Area"	
paint_game_bar_text:
	sll $t2, $a1, 9
	sll $t1, $a0, 2
	add $t1, $t1, $t2		# Offset
	li $t0, BASE_ADDRESS 		# Base address
	add $v0, $t0, $t1		# $v0 = base + offset
	
	li $t3, LIGHTGRAY
	
	sw $t3, -0($v0)
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -20($v0)
	sw $t3, -24($v0)
	sw $t3, -40($v0)
	sw $t3, -48($v0)
	sw $t3, -60($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -0($v0)
	sw $t3, -8($v0)
	sw $t3, -24($v0)
	sw $t3, -40($v0)
	sw $t3, -48($v0)
	sw $t3, -60($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -0($v0)
	sw $t3, -16($v0)
	sw $t3, -24($v0)
	sw $t3, -40($v0)
	sw $t3, -48($v0)
	sw $t3, -52($v0)
	sw $t3, -56($v0)
	sw $t3, -60($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -0($v0)
	sw $t3, -4($v0)
	sw $t3, -16($v0)
	sw $t3, -20($v0)
	sw $t3, -24($v0)
	sw $t3, -32($v0)
	sw $t3, -36($v0)
	sw $t3, -40($v0)
	sw $t3, -48($v0)
	sw $t3, -60($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -52($v0)
	sw $t3, -56($v0)

	jr $ra
	

# ($a0, $a1) = (x, y) of bottom right corner of "Area"
# $a2 = area1, 2, or 3
paint_game_bar_num:
	sll $t2, $a1, 9
	sll $t1, $a0, 2
	add $t1, $t1, $t2		# Offset
	li $t0, BASE_ADDRESS 		# Base address
	add $v0, $t0, $t1		# $v0 = base + offset
	
	li $t3, BRIGHT_RED
	li $t4, MUTED_BLURPLE
	
	beq $a2, 2, paint_two
	beq $a2, 3, paint_three
	
	sw $t3, 20($v0)
	sw $t3, 24($v0)
	sw $t3, 28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 24($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 24($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 20($v0)
	sw $t3, 24($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 24($v0)
	
	jr $ra
	
paint_two:
	sw $t3, 20($v0)
	sw $t3, 24($v0)
	sw $t3, 28($v0)

	subi $v0, $v0, DISPLAY_W
	sw $t3, 24($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 20($v0)
	sw $t3, 28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 20($v0)
	sw $t3, 24($v0)
	sw $t3, 28($v0)

	jr $ra
	
paint_three:
	sw $t3, 20($v0)
	sw $t3, 24($v0)
	sw $t3, 28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 20($v0)
	sw $t3, 24($v0)
	sw $t3, 28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 28($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 20($v0)
	sw $t3, 24($v0)
	sw $t3, 28($v0)
	
	jr $ra


# ($a0, $a1) = (x, y) of bottom right corner of last star	
paint_score:
	sll $t2, $a1, 9
	sll $t1, $a0, 2
	add $t1, $t1, $t2		# Offset
	li $t0, BASE_ADDRESS 		# Base address
	add $v0, $t0, $t1		# $v0 = base + offset
	
	li $t3, EMPTY_COL
	li $t4, EMPTY_COL
	li $t5, EMPTY_COL
	
	lw $t0, star_count
	beqz $t0, colour_score
	li $t5, STAR_COL
	beq $t0, 1, colour_score
	li $t4, STAR_COL
	beq $t0, 2, colour_score
	li $t3, STAR_COL

colour_score:
	sw $t3, -4($v0)
	sw $t3, -12($v0)
	
	sw $t4, -32($v0)
	sw $t4, -40($v0)
	
	sw $t5, -60($v0)
	sw $t5, -68($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	
	sw $t4, -32($v0)
	sw $t4, -36($v0)
	sw $t4, -40($v0)
	
	sw $t5, -60($v0)
	sw $t5, -64($v0)
	sw $t5, -68($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, 0($v0)
	sw $t3, -4($v0)
	sw $t3, -8($v0)
	sw $t3, -12($v0)
	sw $t3, -16($v0)
	
	sw $t4, -28($v0)
	sw $t4, -32($v0)
	sw $t4, -36($v0)
	sw $t4, -40($v0)
	sw $t4, -44($v0)
	
	sw $t5, -56($v0)
	sw $t5, -60($v0)
	sw $t5, -64($v0)
	sw $t5, -68($v0)
	sw $t5, -72($v0)
	
	subi $v0, $v0, DISPLAY_W
	sw $t3, -8($v0)
	
	sw $t4, -36($v0)
	
	sw $t5, -64($v0)
	
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
	li $t0, BASE_ADDRESS 		# Base address
	add $v0, $t0, $t1		# $v0 = base + offset
	jr $ra
	
# Head to next area
next_area:
	li $v0, 32
	li $a0, SLEEP
	syscall

	# Reset star_count
	sw $zero, star_count

	# Increment area
	lw $t0, current_area
	addi $t0, $t0, 1
	sw $t0, current_area
	
	beq $t0, 4, winner
	
	# Update player position
	beq $t0, 3, area3_pos

area2_pos:
	la $t0, player
	li $t1, AREA2_X
	sw $t1, PLAYER_X($t0)
	li $t1, AREA2_Y
	sw $t1, PLAYER_Y($t0)
	
	j reset_player

area3_pos:
	la $t0, player
	li $t1, AREA3_X
	sw $t1, PLAYER_X($t0)
	li $t1, AREA3_Y
	sw $t1, PLAYER_Y($t0)
	
reset_player:
	# Reset player info
	li $t1, RIGHT
	sw $t1, PLAYER_DIR($t0)
	li $t1, START_SPEED
	sw $t1, MOVEMENT_SPEED($t0)
	li $t1, START_JHEIGHT
	sw $t1, JUMP_HEIGHT($t0)
	li $t1, START_JSPAN
	sw $t1, JUMP_SPAN($t0)
	li $t1, FALSE
	sw $t1, IS_BOOSTED($t0)
	sw $t1, ON_PLAT($t0)
	sw $t1, IS_MAX_RIGHT($t0)
	sw $t1, IS_MAX_LEFT($t0)
	sw $t1, IS_MAX_UP($t0)
	li $t1, TRUE
	sw $t1, IS_MAX_DOWN($t0)
	
	j main
	
# Reset to default values
game_reset:
	# Reset game time
	la $t0, time_counter
	li $t1, TIME_RESET
	sw $t1, 0($t0)
	
	# Reset game area and stars
	li $t0, 1
	sw $t0, current_area
	sw $zero, star_count
	
	# Reset player info
	la $t0, player
	li $t1, AREA1_X
	sw $t1, PLAYER_X($t0)
	li $t1, AREA1_Y
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
	sw $t1, IS_BOOSTED($t0)
	sw $t1, IS_WOOSTED($t0)
	sw $t1, ON_PLAT($t0)
	sw $t1, IS_MAX_RIGHT($t0)
	sw $t1, IS_MAX_LEFT($t0)
	sw $t1, IS_MAX_UP($t0)
	li $t1, TRUE
	sw $t1, IS_MAX_DOWN($t0)
	
	
	# Reset pickups
	la $t0, area1_items
	li $t1, FALSE
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	
	la $t0, area2_items
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	
	la $t0, area3_items
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	addi $t0, $t0, ITEM
	sw $t1, IS_CLAIMED($t0)
	
	j main

winner:
	li $a0, 1
	la $a1, win
	li $a2, MUTED_BLURPLE
	li $a3, SESSILE
	jal paint_map
	li $a0, 4
	la $a1, win_border
	li $a2, BLURPLE
	li $a3, SESSILE
	jal paint_map
	
	la $t0, BASE_ADDRESS
	addi $t0, $t0, 33516
	li $t3, PALEBLUE
	
	sw $t3, 44($t0)
	sw $t3, 28($t0)
	sw $t3, 16($t0)
	sw $t3, 0($t0)
	sw $t3, -8($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, 44($t0)
	sw $t3, 40($t0)
	sw $t3, 28($t0)
	sw $t3, 16($t0)
	sw $t3, 4($t0)
	sw $t3, -4($t0)
	sw $t3, -12($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, 44($t0)
	sw $t3, 36($t0)
	sw $t3, 28($t0)
	sw $t3, 16($t0)
	sw $t3, 4($t0)
	sw $t3, -12($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, 44($t0)
	sw $t3, 32($t0)
	sw $t3, 28($t0)
	sw $t3, 16($t0)
	sw $t3, 4($t0)
	sw $t3, -12($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, 44($t0)
	sw $t3, 28($t0)
	sw $t3, 16($t0)
	sw $t3, 4($t0)
	sw $t3, -12($t0)

	la $t0, BASE_ADDRESS
	addi $t0, $t0, 32976
	li $t3, STAR_COL
	
	sw $t3, -4($t0)
	sw $t3, -12($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, -4($t0)
	sw $t3, -8($t0)
	sw $t3, -12($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, 0($t0)
	sw $t3, -4($t0)
	sw $t3, -8($t0)
	sw $t3, -12($t0)
	sw $t3, -16($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, -8($t0)
	
	la $t0, BASE_ADDRESS
	addi $t0, $t0, 33080
	
	sw $t3, -4($t0)
	sw $t3, -12($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, -4($t0)
	sw $t3, -8($t0)
	sw $t3, -12($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, 0($t0)
	sw $t3, -4($t0)
	sw $t3, -8($t0)
	sw $t3, -12($t0)
	sw $t3, -16($t0)
	
	subi $t0, $t0, DISPLAY_W
	sw $t3, -8($t0)

end:
	li $v0, 10			# Terminate the program gracefully
	syscall

