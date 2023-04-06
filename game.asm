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
.eqv	HEAP_ADDRESS	0x10040000
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
.eqv	AREA1_N		10

# Rectangle info indices:
# Uses OBJ_X, OBJ_Y, OBJ_W, OBJ_H
.eqv	RECT_ARR_W	16

# Moving object indices:
.eqv	OBJ_X		0
.eqv	OBJ_Y		4
.eqv	OBJ_W		8
.eqv	OBJ_H		12
.eqv	OBJ_DIR		16
.eqv	MOVE_LEN	20
.eqv	MOVE_FRAME	24
.eqv	MOVE_STEP	28

# Directions:
.eqv	LEFT		-2
.eqv	RIGHT		2
.eqv	UP		1
.eqv	DOWN		0
.eqv	VERT		3
.eqv	HORZ		4

# Player info indices:
.eqv	POS_X		0
.eqv	POS_Y		4
.eqv	PLAYER_W	8
.eqv	PLAYER_H	12
.eqv	DIR		16
.eqv	MOVEMENT_SPEED	20
.eqv	JUMP_HEIGHT	24
.eqv	JUMP_SPAN	28
.eqv	IS_MAX_LEFT	32
.eqv	IS_MAX_RIGHT	36
.eqv	IS_MAX_UP	40
.eqv	IS_MAX_DOWN	44

# Player animation
.eqv	STACK_BOTTOM	0x10008000
.eqv	QUEUE_START	0
.eqv	QUEUE_END	4
.eqv	QUEUE_BEGIN	8
.eqv	ERASE		0
.eqv	PAINT		1
.eqv	FREEZE_FRAME	-1

.eqv	TIME_RESET	6000
.eqv	PLAYER_RESET	1000

.data
# Empty space to prevent game data from being overwritten due to large bitmap size
padding:	.space	36000

# Area Maps:		Maps are composed of rectangles. If there are n rectangles, then the array is 4xn
# 			Every rectangle is saved as (x of top left corner, y of top left corner, width, height)
border:		.word	0, 0, 128, 8, 0, 120, 128, 8, 120, 8, 8, 112, 0, 8, 8, 112
area1:		.word	40, 30, 8, 90, 48, 92, 36, 6, 106, 106, 14, 14, 70, 54, 19, 5, 
			78, 28, 42, 6, 8, 19, 14, 4, 8, 48, 14, 4, 26, 72, 14, 4,
			8, 93, 14, 4, 26, 116, 14, 4			
			
# Moving Platforms:	(x,y) top left corner during highest, leftmost position
#			(x, y, w, h, dir, move_len, move_frame, move_step)
test_platform:	.word 	94, 40, 19, 5, VERT, 40, 0, 1

time_counter:	.word	TIME_RESET
player_counter:	.word	PLAYER_RESET

# Queue:		(start address, end address, true beginning)
queue:		.word	0:3

# Player info:		pos_x	pos_y	player_w	player_h	dir
player:		.word	63, 	119, 	12,		9,		RIGHT,
#			movement_speed	jump_height	jump_span
			2, 		16, 		3,
#			is_max_left	is_max_right	is_max_up	is_max_down
			0,		0,		0,		1
			
newline:	.asciiz "\n"

.text
.globl main
main:
	li $s0, BASE_ADDRESS 		# $s0 stores the base address for display
	la $s1, player			# $s1 stores the player info
	li $s7,	KEYSTROKE_EVENT		# $s7 stores the address for keystroke event

	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall

	# Paint game border
	li $a0, BORDER_N		# Number of rectangles to paint
	la $a1, border			# Array of rectangles to paint
	li $a2, WALL_COL		# Colour of rectangles to paint
	jal paint_map
	
	# Paint map of Area1
	li $a0, AREA1_N			# Number of rectangles to paint
	la $a1, area1			# Array of rectangles to paint
	jal paint_map
	
	# Save queue start (bottom of stack)
	la $t0, queue
	sw $sp, QUEUE_START($t0)
	sw $sp, QUEUE_BEGIN($t0)	
	
	# Enqueue painting start player
	li $a0, RIGHT			# Direction to paint
	li $a1, PAINT			# Type to paint
	jal get_player_pos		# Position to paint
	move $a2, $v0
	jal enqueue_player
	
game_running:
	# When queue_start == queue_end, reclaim space
	la $t0, queue
	lw $t1, QUEUE_START($t0)
	lw $t2, QUEUE_END($t0)
	bne $t1, $t2, game_main
	
	# But not when the queue is already emptied
	lw $t3, QUEUE_BEGIN($t0)
	bne $t1, $t3, reclaim_space
	
game_main:
	# Gravity: let player fall if it can still move down
	lw $t3, IS_MAX_DOWN($s1)
	beqz $t3, fall_player
	
	# Decrement game time counter
	la $t0, time_counter
	lw $t1, 0($t0)
	subi $t1, $t1, 1
	sw $t1, 0($t0) 
	bnez $t1, player_main
	
	# Reset game time counter
	li $t1, TIME_RESET
	sw $t1, 0($t0)
	
	# Paint one frame of game
	jal game_animation
	
player_main:
	# Decrement player time counter
	la $t0, player_counter
	lw $t1, 0($t0)
	subi $t1, $t1, 1
	sw $t1, 0($t0) 
	bnez $t1, check_keypress
	
	# Reset player time counter
	li $t1, PLAYER_RESET
	sw $t1, 0($t0)
	
	# Paint one frame of player if queue not empty
	la $t0, queue
	lw $t1, QUEUE_START($t0)
	lw $t2, QUEUE_END($t0)
	beq $t1, $t2, check_keypress
	j player_animation
	
check_keypress:
	lw $s6, 0($s7)
	bne $s6, 1, game_running
	lw $s6, 4($s7)
	
	beq $s6, 0x62, end		# Hit 'b' to end program
	beq $s6, 0x20, jump_player	# ASCII code of ' ' is 0x20
	beq $s6, 0x61, move_left	# ASCII code of 'a' is 0x61
	beq $s6, 0x64, move_right 	# ACSII code of 'd' is 0x64
	
	li $s6, 0
	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall
	j game_running


# -----------------------+= PLAYER MOVEMENT =+-----------------------
# Move player in the direction of the key event, by the number of units
# specified by its movement_speed. Update the direcion the player is facing
move_left:
	lw $t7, MOVEMENT_SPEED($s1)
	
	# Save current position
	jal get_player_pos
	move $s4, $v0
	
	# Reset collision tracking
	sw $zero, IS_MAX_RIGHT($s1)
	sw $zero, IS_MAX_UP($s1)
	
	# Check if the player can move more left
	lw $t3, IS_MAX_LEFT($s1)
	bnez $t3, game_main

	# Check row-wise collision
	move $a0, $s4			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, LEFT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	sub $t8, $t8, $v1		# player_x - actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_LEFT($s1)	# Update player is_max_left

	# Enqueue erasing old player
	lw $a0, DIR($s1)		# Direction to paint
	li $a1, ERASE			# Type to paint
	move $a2, $s4			# Position to paint
	jal enqueue_player
	
	# Enqueue painting new player
	li $a0, LEFT			# Direction to paint
	li $a1, PAINT			# Type to paint
	jal get_player_pos		# Position to paint
	move $a2, $v0
	jal enqueue_player
	
	# Player is now facing left
	li $t3, LEFT
	sw $t3, DIR($s1)
	
	# Check for fall
	move $a0, $v0			# Current position
	li $a1, 1			# Expected x movement
	li $a2, DOWN			# Direction of movement
	jal collision_check
	sw $v0, IS_MAX_DOWN($s1)	# Update player is_max_down
	j game_running

move_right:
	lw $t7, MOVEMENT_SPEED($s1)
	
	# Save current position
	jal get_player_pos
	move $s4, $v0
	
	# Reset collision tracking
	sw $zero, IS_MAX_LEFT($s1)
	sw $zero, IS_MAX_UP($s1)
	
	# Check if the player can move more right
	lw $t3, IS_MAX_RIGHT($s1)
	bnez $t3, game_main
	
	# Check row-wise collision
	move $a0, $v0			# Current position
	move $a1, $t7			# Expected x movement
	li $a2, RIGHT			# Direction of movement
	jal collision_check

	lw $t8, POS_X($s1)
	add $t8, $t8, $v1		# player_x + actual x movement
	sw $t8, POS_X($s1)		# Update player_x
	sw $v0, IS_MAX_RIGHT($s1)	# Update player is_max_right
	
	# Enqueue erasing old player
	lw $a0, DIR($s1)		# Direction to paint
	li $a1, ERASE			# Type to paint
	move $a2, $s4			# Position to paint
	jal enqueue_player
	
	# Enqueue painting new player
	li $a0, RIGHT			# Direction to paint
	li $a1, PAINT			# Type to paint
	jal get_player_pos		# Position to paint
	move $a2, $v0
	jal enqueue_player
	
	# Player is now facing right
	li $t3, RIGHT
	sw $t3, DIR($s1)
	
	# Check for fall
	move $a0, $v0			# Current position
	li $a1, 1			# Expected x movement
	li $a2, DOWN			# Direction of movement
	jal collision_check
	sw $v0, IS_MAX_DOWN($s1)	# Update player is_max_down
	j game_running


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
	
	# Save current position
	jal get_player_pos
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

	# Erase current player position
	#move $v0, $s4
	#jal erase
	
	# Draw new player position
	#jal get_player_pos
	#jal test
	
	# Enqueue erasing old player
	lw $a0, DIR($s1)		# Direction to paint
	li $a1, ERASE			# Type to paint
	move $a2, $s4			# Position to paint
	jal enqueue_player
	
	# Enqueue painting new player
	lw $a0, DIR($s1)		# Direction to paint
	li $a1, PAINT			# Type to paint
	jal get_player_pos		# Position to paint
	move $a2, $v0
	jal enqueue_player
	
	jal enqueue_freeze_frame

jump_next:	
	sra $s6, $s6, 1			# Next jump height (divide by 2)
	beqz $s6, game_running
	j jump_up


# -----------------------+= PLAYER FALLING =+------------------------
# Fall player until they collide with the ground or a platform
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

	# Erase current player position
	#move $v0, $s4
	#jal erase
	
	# Draw new player position
	#jal get_player_pos
	#jal test
	
	# Enqueue erasing old player
	lw $a0, DIR($s1)		# Direction to paint
	li $a1, ERASE			# Type to paint
	move $a2, $s4			# Position to paint
	jal enqueue_player
	
	# Enqueue painting new player
	lw $a0, DIR($s1)		# Direction to paint
	li $a1, PAINT			# Type to paint
	jal get_player_pos		# Position to paint
	move $a2, $v0
	jal enqueue_player

	jal enqueue_freeze_frame

fall_next:	
	sll $s6, $s6, 1			# Next falling height (multiply by 2)
	beqz $s6, game_running
	j fall_down


# ---------------------+= CHECKING COLLISIONS =+---------------------
# $a1 = expected movement (>0)
# $a2 = direction of movement
# $v0 = 1 or 0, if a collision occurred or not
# $v1 = actual movement
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
	addi $t8, $t8, 1		# bottom left corner
	beq $a2, LEFT, collision_outer
	
	move $t8, $t4
	move $t4, $t9
	sub $t9, $t9, $t2		
	addi $t9, $t9, 1		# top left corner
	move $t2, $t3
	beq $a2, UP, collision_outer
	
	move $t9, $t4
	li $t6, 1
	
	
collision_outer:
	li $t1, 0			# Area of collision depends on player's height or width
	
collision_inner:
	mult $t0, $t6
	mflo $t5
	beq $a2, UP, collision_y
	beq $a2, DOWN, collision_y

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
	beq $t3, 0x6d4886, collision_true

	# This square is safe
	addi $t1, $t1, 1		# Next collision square
	blt $t1, $t2, collision_inner	# While this movement step hasn't been completed
	
	# The step is safe
	addi $t0, $t0, 1		# Next movement step
	ble $t0, $a1, collision_outer	# While movement < expected_movement

collision_false:
	li $v0, 0			# No collision occurred
	move $v1, $a1			# Actual movement is expected movement
	jr $ra

collision_true:
	li $v0, 1			# A collision occurred
	subi $t0, $t0, 1		# Last step that didn't cause a collision
	move $v1, $t0			# Actual movement
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

# Add a player frame to the end of the queue (top of the stack)
# $a0 = direction to draw
# $a1 = type to draw
# $a2 = position to draw
enqueue_player:	
	# Enqueue the player frame
	addi $sp, $sp, -12		# Make space in stack
	sw $a0, 8($sp)			# Direction to paint
	sw $a1, 4($sp)			# Type to paint
	sw $a2, 0($sp)			# Position to paint
	
	# Update queue_end
	la $t0, queue
	sw $sp, QUEUE_END($t0)

	jr $ra
	
	
enqueue_freeze_frame:	
	# Enqueue a freeze frame
	addi $sp, $sp, -8
	li $t0, FREEZE_FRAME
	sw $t0, 0($sp)
	sw $t0, 4($sp)
	
	# Update queue_end
	la $t0, queue
	sw $sp, QUEUE_END($t0)
	
	jr $ra

reclaim_space:
	la $t0, queue
	lw $t1, QUEUE_BEGIN($t0)

reclaim_word:
	addi $sp, $sp, 4
	bne $sp, $t1, reclaim_word
	
	sw $t1, QUEUE_START($t0)
	sw $t1, QUEUE_END($t0)
	j game_main
	
# -----------------------+= PAINT FUNCTIONS =+-----------------------
	
# Paint the map of area provided by...
# $a0 = number of rectangles to paint
# $a1 = array of rectangles to paint
# $a2 = colour of rectangles to paint
paint_map:
	sll $t0, $a0, 4
	li $t1, 0
	
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

paint_row:
	sw $a2, 0($t4)			# Colour pixel
	addi $t4, $t4, 4		# Next pixel in row
	blt $t4, $t8, paint_row		# Continue colouring until x limit is reached
	
	move $t4, $t6 			# Reset x position
	addi $t4, $t4, DISPLAY_W	# Jump to next row
	addi $t8, $t8, DISPLAY_W	# Jump to next row
	move $t6, $t4			# Save x position
	addi $t5, $t5, 1		# Increment counter
	blt $t5, $t9, paint_row		# Continue if $t5 < rectangle_height

	#li $v0, 32
	#li $a0, 40			# Sleep 40ms
	#syscall
	
	addi $t1, $t1, RECT_ARR_W	# Get next possible rectangle (increment by width of rectangle array)
	blt $t1, $t0, paint_rectangle	# Check if there are still rectangles to paint
	jr $ra

# Dequeue one frame
player_animation:
	la $t0, queue
	lw $t1, QUEUE_START($t0)
	
	lw $s5, -4($t1)			# Direction to paint
	addi $t1, $t1, -4		# "reclaim" space
	sw $t1, QUEUE_START($t0)
	
	# Check for freeze frame
	beq $s5, FREEZE_FRAME, game_running

	lw $s4, -4($t1)			# Type to paint
	lw $s3, -8($t1)			# Position to paint
	
	addi $t1, $t1, -8		# "reclaim" space
	sw $t1, QUEUE_START($t0)
	
	beq $s4, ERASE, erase

colour:
	li $t3, 0xadd07d
	li $t4, 0x5bbe74
	li $t5, 0x332935
	j test_draw

erase:
	li $t3, BG_COL
	li $t4, BG_COL
	li $t5, BG_COL

test_draw:
	beq $s5, LEFT, flipped
	sw $t3, 0($s3)
	sw $t3, -20($s3)
	sw $t3, -40($s3)
	sw $t3, -44($s3)
	
	li $t6, 0xff0000
	sw $t6, 0($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, 0($s3)
	sw $t3, -4($s3)
	sw $t3, -20($s3)
	sw $t3, -24($s3)
	sw $t3, -36($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -4($s3)
	sw $t3, -8($s3)
	sw $t3, -12($s3)
	sw $t3, -16($s3)
	sw $t3, -20($s3)
	sw $t3, -24($s3)
	sw $t3, -32($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -8($s3)
	sw $t3, -12($s3)
	sw $t3, -16($s3)
	sw $t3, -20($s3)
	sw $t3, -24($s3)
	sw $t4, -28($s3)
	sw $t3, -32($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -4($s3)
	sw $t3, -8($s3)
	sw $t3, -12($s3)
	sw $t4, -16($s3)
	sw $t4, -20($s3)
	sw $t3, -24($s3)
	sw $t3, -28($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, 0($s3)
	sw $t3, -4($s3)
	sw $t3, -8($s3)
	sw $t3, -12($s3)
	sw $t3, -16($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t5, 0($s3)
	sw $t3, -4($s3)
	sw $t5, -8($s3)
	sw $t3, -12($s3)
	sw $t3, -16($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, 0($s3)
	sw $t3, -4($s3)
	sw $t3, -8($s3)
	sw $t3, -12($s3)
	sw $t3, -16($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, 0($s3)
	sw $t3, -16($s3)
	
	beq $s4, ERASE, player_animation
	j game_running
	
flipped:
	sw $t3, -44($s3)
	sw $t3, -28($s3)
	sw $t3, -4($s3)
	sw $t3, 0($s3)
	
	li $t6, 0xff0000
	sw $t6, 0($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -44($s3)
	sw $t3, -40($s3)
	sw $t3, -28($s3)
	sw $t3, -24($s3)
	sw $t3, -8($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -40($s3)
	sw $t3, -36($s3)
	sw $t3, -32($s3)
	sw $t3, -28($s3)
	sw $t3, -24($s3)
	sw $t3, -20($s3)
	sw $t3, -12($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -36($s3)
	sw $t3, -32($s3)
	sw $t3, -28($s3)
	sw $t3, -24($s3)
	sw $t3, -20($s3)
	sw $t4, -16($s3)
	sw $t3, -12($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -40($s3)
	sw $t3, -36($s3)
	sw $t3, -32($s3)
	sw $t4, -28($s3)
	sw $t4, -24($s3)
	sw $t3, -20($s3)
	sw $t3, -16($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -44($s3)
	sw $t3, -40($s3)
	sw $t3, -36($s3)
	sw $t3, -32($s3)
	sw $t3, -28($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t5, -44($s3)
	sw $t3, -40($s3)
	sw $t5, -36($s3)
	sw $t3, -32($s3)
	sw $t3, -28($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -44($s3)
	sw $t3, -40($s3)
	sw $t3, -36($s3)
	sw $t3, -32($s3)
	sw $t3, -28($s3)
	
	subi $s3, $s3, DISPLAY_W
	sw $t3, -44($s3)
	sw $t3, -28($s3)
	
	beq $s4, ERASE, player_animation
	j game_running
	

game_animation:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# Erase
	li $a0, 1			# Number of rectangles to draw
	la $a1, test_platform		# Array of rectangles to draw
	li $a2, BG_COL			# Colour of rectangles to draw
	jal paint_map
	
	la $t0, test_platform
	lw $t1, MOVE_LEN($t0)
	lw $t2, MOVE_FRAME($t0)		# Get current frame
	lw $t3, OBJ_DIR($t0)
	lw $t4, MOVE_STEP($t0)
	
	bge $t2, $t1, swap_dir
	bltz $t2, swap_dir
	j increment_plat

swap_dir:
	sub $t4, $zero, $t4
	sw $t4, MOVE_STEP($t0)
	
increment_plat:
	add $t2, $t2, $t4
	sw $t2, MOVE_FRAME($t0)

	bne $t3, HORZ, vertical_movement
	lw $t8, OBJ_X($t0)
	add $t8, $t8, $t4		# Add current frame to obj_x or obj_y
	sw $t8, OBJ_X($t0)
	j draw_platform
	
vertical_movement:
	lw $t8, OBJ_Y($t0)
	add $t8, $t8, $t4		# Add current frame to obj_x or obj_y
	sw $t8, OBJ_Y($t0)
	
draw_platform:
	li $a0, 1			# Number of rectangles to draw
	la $a1, test_platform		# Array of rectangles to draw
	li $a2, 0x6d4886		# Colour of rectangles to draw
	jal paint_map
	
	li $v0, 32
	li $a0, 40			# Sleep 40ms
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

error_checking:
	# If 9999 ever prints there's something wrong
	li $v0, 1
	li $a0, 9999
	syscall

end:
	li $v0, 10			# Terminate the program gracefully
	syscall

