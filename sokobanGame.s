# The multiplayer competitive mode enhancement has been implemented
# The multiplayer enhancement spans throughout the code.
# From line 42-67, the code is for prompting the user for the number of players
# and it creates a stack pointer in which the number of moves used by each player
# and their corresponding player index number is stored.
# Between line 434-581, the code stores the number of moves used and their index
# number into the stack pointer for each individual player, additionally,
# if all players have had their turn, then the bubble sort algorithm sorts
# all of the moves used by each player and their corresponding index.
# Using this information, the leaderboard will print the sorted number of moves
# and the corresponding player number.
.data
gridsize:       .byte 8,8  # grid size (row, col) (includes walls within it)
character:      .byte 0,0  # Stores character position
box:            .byte 0,0  # Stores box position
target:         .byte 0,0  # Stores target position
initial_char:   .byte 0,0  # Stores character position for restart
initial_box:    .byte 0,0  # Stores box position for restart
initial_target: .byte 0,0  # Stores initial target position for restart
                .align 2
seed:           .word 0    # seed for algorithm
players:        .word 0    # number of total players
rounds:         .word 0    # numbers of rounds completed
move_count:     .word 0    # move count for current player
player_moves:   .word 0    # array of all player moves
player_indexes: .word 0    # array of all player indexes
invalid:        .asciz "Invalid or useless input! Try again.\n"
finished_pt1:   .asciz "You have beat the game in "
finished_pt2:   .asciz " moves!\n"
forfeit:        .asciz "You have forfeited the match!\n"
replay:         .asciz "Press 'r' to restart, 'n' for a new game, or anything else to exit!\n"
quit:           .asciz "Thanks for playing!\n"
prompt_players: .asciz "Enter the number of players: "
new_line:       .asciz "\n"
player_print:   .asciz ". Player #"
move_print:     .asciz ", Moves: "
leaderboard:    .asciz "LEADERBOARD\n"

.text
.globl _start

_start:
	# initializing number of players
    la a0, prompt_players
    li a7, 4         
    ecall
    li a7, 5        
    ecall
    la t0, players
    sw a0, 0(t0)    
    la a0, new_line
    li a7, 4         
    ecall
	
	# creating stack pointer
	# stack pointer for player moves
	la t0, players
	lw t1, 0(t0)
	slli t1, t1, 3
	sub sp, sp, t1
	la t0, player_moves
	sw sp, 0(t0)
	
	# stack pointer for player indexes
	sub sp, sp, t1
	la t0, player_indexes
	sw sp, 0(t0)
	
	# stack pointer for board
	la t1, gridsize     
	lb a2, 0(t1)   	# rows of grid
	lb a3, 1(t1)    # columns of grid
	mul t0, a2, a3
	slli t0, t0, 3
	sub sp, sp, t0

generate_seed:
	# randomize seed based on current time
	la t0, seed
	li a7, 30
	ecall
	sw a0, 0(t0)

	# storing gridsizes
	la t1, gridsize     
	lb a2, 0(t1)   	# rows of grid
	lb a3, 1(t1)    # columns of grid
	mul t0, a2, a3
	addi a2, a2, -2 # rows of playable area
	addi a3, a3, -2 # columns of playable area
	
create_character:
	# generate character
	mv a0, a2
	jal ra, notrand     # call algorithm on row coordinate
	addi a0, a0, 1
	la t0, character
	la t1, initial_char
	sb a0, 0(t0)
	sb a0, 0(t1)
	mv a0, a3
	
	jal ra, notrand     # call algorithm on col coordinate
	addi a0, a0, 1
	la t0, character + 1
	la t1, initial_char + 1
	sb a0, 0(t0)
	sb a0, 0(t1)
	
create_target:
	# generate target
	mv a0, a2
	jal ra, notrand     # call algorithm on row coordinate
	addi a0, a0, 1
	la t0, target
	la t1, initial_target
	sb a0, 0(t0)
	sb a0, 0(t1)
	mv a0, a3
	jal ra, notrand     # call algorithm on col coordinate
	addi a0, a0, 1
	la t0, target + 1
	la t1, initial_target + 1
	sb a0, 0(t0)
	sb a0, 0(t1)
	
	lb t0, target
	lb t1, character
	beq t0, t1, generate_seed  # check if target and character are in the same spot for rows
	lb t0, target + 1
	lb t1, character + 1
	beq t0, t1, generate_seed  # check if target and character are in the same spot for cols
	
create_box:
	# generate box
	mv a0, a2
	jal ra, notrand
	addi a0, a0, 1
	la t0, box
	la t1, initial_box
	sb a0, 0(t0)
	sb a0, 0(t1)
	mv a0, a3
	jal ra, notrand
	addi a0, a0, 1
	la t0, box + 1
	la t1, initial_box + 1
	sb a0, 0(t0)
	sb a0, 0(t1)
	
	lb t0, box     
	lb t1, box + 1 
	lb t2, character
	lb t3, character + 1
	lb t4, target
	lb t5, target + 1
	
	# checking to prevent collison spawn points
	beq t0, t2, generate_seed
	beq t0, t4, generate_seed
	beq t1, t3, generate_seed
	beq t1, t5, generate_seed
	
	# checking to prevent impossible box spawn points
	li t6, 1
	beq t0, t6, check_top
	beq t1, t6, check_left
	beq t0, a2, check_bottom
	beq t1, a3, check_right
	j print
	
check_top:
	beq t1, t6, generate_seed
	beq t1, a3, generate_seed
	bne t4, t6, generate_seed
	j print
	
check_left:
	beq t0, t6, generate_seed
	beq t0, a2, generate_seed
	bne t5, t6, generate_seed
	j print
	
check_bottom:
	beq t1, t6, generate_seed
	beq t1, a3, generate_seed
	bne t4, a2, generate_seed
	j print
	
check_right:
	beq t0, t6, generate_seed
	beq t0, a2, generate_seed
	bne t5, a3, generate_seed
	j print
	
restart:
	# if player requests to restart with the same board or for multiplayer
	li t1, 0
	la t4, move_count
	sb t1, 0(t4)
	
    la t0, initial_char
    lb t1, 0(t0)
    la t2, character
    sb t1, 0(t2)
    lb t1, 1(t0)
    sb t1, 1(t2)
	
    la t0, initial_target
    lb t1, 0(t0)
    la t2, target
    sb t1, 0(t2)
    lb t1, 1(t0)
    sb t1, 1(t2)
	
    la t0, initial_box
    lb t1, 0(t0)
    la t2, box
    sb t1, 0(t2)
    lb t1, 1(t0)
    sb t1, 1(t2)
    j print

	
game_loop:
    li a7, 12     
    ecall        
    mv t0, a0      
    la a0, new_line
    li a7, 4   
    ecall   
	la t1, gridsize     
	lb a2, 0(t1)   	# rows of grid
	lb a3, 1(t1)    # columns of grid
	addi a2, a2, -2 # rows of playable area
	addi a3, a3, -2
	
    li t1, 119
    beq t0, t1, move_up
    li t1, 97
    beq t0, t1, move_left
    li t1, 115
    beq t0, t1, move_down
    li t1, 100
    beq t0, t1, move_right
    li t1, 114        # if 'r' is pressed, restart game with current board
    beq t0, t1, restart
    li t1, 110        # if 'n' is pressed, start a new game
    beq t0, t1, _start
    li t1, 103        # if 'g' is pressed, give up
    beq t0, t1, give_up
	j invalid_input # for invalid buttons
	
move_up:
	li t5, -1          # number by which player moves
	li t6, 1           # maximum number to which player can move to
	lb t0, character
	lb t1, box
	beq t0, t6, invalid_input  # if player is at an unmovable area, invalid input
	add t3, t0, t5        
	beq t3, t1, box_same_row  # if player moves to same row as box
	add t0, t0, t5
	la t4, character
	sb t0, 0(t4)
	j print
	
move_left:
	li t5, -1          # number by which player moves
	li t6, 1           # maximum number to which player can move to
	lb t0, character + 1
	lb t1, box + 1
	beq t0, t6, invalid_input  # if player is at an unmovable area, invalid input
	add t3, t0, t5        
	beq t3, t1, box_same_col  # if player moves to same row as box
	add t0, t0, t5
	la t4, character + 1
	sb t0, 0(t4)
	j print
	
move_down:
	li t5, 1          # number by which player moves
	mv t6, a2           # maximum number to which player can move to
	lb t0, character
	lb t1, box
	beq t0, t6, invalid_input  # if player is at an unmovable area, invalid input
	add t3, t0, t5        
	beq t3, t1, box_same_row  # if player moves to same row as box
	add t0, t0, t5
	la t4, character
	sb t0, 0(t4)
	j print
	
move_right:
	li t5, 1          # number by which player moves
	mv t6, a3           # maximum number to which player can move to
	lb t0, character + 1
	lb t1, box + 1
	beq t0, t6, invalid_input  # if player is at an unmovable area, invalid input
	add t3, t0, t5        
	beq t3, t1, box_same_col  # if player moves to same row as box
	add t0, t0, t5
	la t4, character + 1
	sb t0, 0(t4)
	j print
	
box_same_row:
	lb a4, character + 1
	lb a5, box + 1
	beq a4, a5, box_collision_vertical  # if player is in same column as box
	add t0, t0, t5  # otherwise, just player moves
	la t4, character
	sb t0, 0(t4)
	j print
	
box_collision_vertical:
	beq t1, t6, invalid_input  # if box is in an unmovable position, invalid input
	add t0, t0, t5 # otherwise, both box and player move
	add t1, t1, t5
	la t4, character
	sb t0, 0(t4)
	la t4, box
	sb t1, 0(t4)
	j print
	
box_same_col:
	lb a4, character
	lb a5, box
	beq a4, a5, box_collision_horizontal  # if player is in same row as box
	add t0, t0, t5  # otherwise, just player moves
	la t4, character + 1
	sb t0, 0(t4)
	j print
	
box_collision_horizontal:
	beq t1, t6, invalid_input  # if box is in an unmovable position, invalid input
	add t0, t0, t5 # otherwise, both box and player move
	add t1, t1, t5
	la t4, character + 1
	sb t0, 0(t4)
	la t4, box + 1
	sb t1, 0(t4)
	j print
	
invalid_input:
    la a0, invalid
    li a7, 4   
    ecall   
    j game_loop

print:
	mv t0, sp  # address of board
	li t2, 0        # rows
	
outer:
	li t3, 0        # columns
	
inner:
	la t1, gridsize     
	lb t4, 0(t1)    # rows
	lb t5, 1(t1)    # columns
	addi t4, t4, -1 # rows
	addi t5, t5, -1 # columns
	beqz t2, build_wall
	beqz t3, build_wall
	beq t2, t4, build_wall
	beq t3, t5, build_wall
	lb t4, character
	lb t5, character + 1
	bne t4, t2, check_box
	bne t5, t3, check_box
	li t6, 'P'
	sb t6, 0(t0)
	j continue

check_box:
	lb t4, box
	lb t5, box + 1
	bne t4, t2, check_target
	bne t5, t3, check_target
	li t6, '#'
	sb t6, 0(t0)
	j continue
	
check_target:
	lb t4, target
	lb t5, target + 1
	bne t4, t2, empty_space
	bne t5, t3, empty_space
	li t6, 'X'
	sb t6, 0(t0)
	j continue
	
empty_space:
	li t6, ' '
	sb t6, 0(t0)
	j continue

build_wall:
	li t6, '='
	sb t6, 0(t0)
	
continue:
	la t1, gridsize 
	lb t4, 0(t1)    # rows
	lb t5, 1(t1)    # columns
	addi t0, t0, 1
	addi t3, t3, 1
	blt t3, t5, inner
	li t6, 10
	sb t6, 0(t0)
	addi t0, t0, 1
	addi t2, t2, 1
	blt t2, t4, outer
	li t6, 0
	sb t6, 0(t0)
	mv a0, sp
	li a7, 4
	ecall
	lw t1, move_count
	addi t1, t1, 1
	la t4, move_count
	sb t1, 0(t4)
	lb t0, box
	lb t1, target
	beq t0, t1, win_check
	j game_loop

win_check: 
	lb t0, box + 1
	lb t1, target + 1
	beq t0, t1, win
	j game_loop
	
win: 
	lw t1, move_count	
	addi t1, t1, -1
	lw t2, rounds
	lw t3, player_moves
	lw t4, player_indexes
	slli t5, t2, 2
	add t3, t3, t5
	sw t1, 0(t3)
	add t4, t4, t5
	sw t2, 0(t4)
    la a0, finished_pt1
    li a7, 4   
    ecall
	mv a0, t1
    li a7, 1   
    ecall
    la a0, finished_pt2
    li a7, 4   
    ecall
    la t0, players
	lw t1, 0(t0)
    la t2, rounds
	lw t3, 0(t2)
	addi t3, t3, 1
	sw t3, 0(t2)
	li t6, 1
	bne t1, t3, restart
	bgt t1, t6, sort
	j repeat
	
give_up:
	li t1, 999
	lw t2, rounds
	lw t3, player_moves
	lw t4, player_indexes
	slli t5, t2, 2
	add t3, t3, t5
	sw t1, 0(t3)
	add t4, t4, t5
	sw t2, 0(t4)
    la a0, forfeit
    li a7, 4   
    ecall
    la t0, players
	lw t1, 0(t0)
    la t2, rounds
	lw t3, 0(t2)
	addi t3, t3, 1
	sw t3, 0(t2)
	li t6, 0
	bne t1, t3, restart
	bgt t1, t6, sort
	j repeat
	
sort:
	lw t0, players
	lw t1, player_moves
	lw t2, player_indexes
	j bubble_sort
	
# The following code was generated with the help of ChatGPT [2]
# (Citation at the the bottom of the code).
# The bubble sort alogorithm and print logic for leaderbaord were partly
# generated with ChatGPT
bubble_sort:
    addi t3, zero, 0        

outer_loop:
    li t4, 0         
    li t5, 1 

inner_loop:
	lw t1, player_moves
	lw t2, player_indexes
	add t1, t1, t4
	add t2, t2, t4
    lw t6, 0(t1)             
    lw a2, 4(t1)          
    blt t6, a2, no_swap     
	beq t6, a2, no_swap
    sw a2, 0(t1)           
    sw t6, 4(t1)              
    lw a3, 0(t2)         
    lw a4, 4(t2)        
    sw a4, 0(t2)              
    sw a3, 4(t2)              

no_swap:
	lw t0, players
	addi t5, t5, 1
    addi t4, t4, 4           
    bge t5, t0, end_inner_loop 
    j inner_loop       

end_inner_loop:
    addi t3, t3, 1          
    blt t3, t0, outer_loop   
    j print_leaderboard
	
	
print_leaderboard:
    li t4, 0  
	lw t0, players
	slli t0, t0, 2
	li t6, 1
    li a0, 10                
    li a7, 11                 
    ecall
    la a0, leaderboard
    li a7, 4   
    ecall

print_loop:
    bge t4, t0, end_print  
	lw t2, player_indexes
	add t2, t2, t4
	lw t1, player_moves
	add t1, t1, t4
    mv a0, t6
    li a7, 1   
    ecall
    la a0, player_print
    li a7, 4   
    ecall
	lw t5, 0(t2)
	addi t5, t5, 1
    mv a0, t5                
    li a7, 1          
    ecall
    la a0, move_print
    li a7, 4   
    ecall
    lw a0, 0(t1)            
    li a7, 1           
    ecall
    la a0, new_line              
    li a7, 4             
    ecall
    addi t4, t4, 4            
	addi t6, t6, 1
    j print_loop             

end_print:
    la a0, new_line                
    li a7, 4                 
    ecall
    j repeat

repeat:
	li t1, 0
	la t4, rounds
	sb t1, 0(t4)
    la a0, replay
    li a7, 4   
    ecall
    li a7, 12       
    ecall          
    mv t0, a0 
    la a0, new_line
    li a7, 4   
    ecall
    li t1, 114        # if 'r' is pressed, restart game with current board
    beq t0, t1, restart
    li t1, 110        # if 'n' is pressed, start a new game
    beq t0, t1, _start
	j exit
	
exit:
    la a0, quit
    li a7, 4   
    ecall
    li a7, 10
    ecall

# The following code was generated with the help of ChatGPT [2]
# The Line Linear Congruential Generator was partly generated by ChatGPT
notrand:
	la t0, seed
	lw t1, 0(t0)
	li t2, 1664525
	li t3, 1013904223
	mul t1, t1, t2
	add t1, t1, t3
	sw t1, 0(t0)
	remu a0, t1, a0
	jr ra

# Algorithm Name: Linear Congruential Generator
# Algorithm Creator: W. E. Thomson and A. Rotenberg.
# Link: https://en.wikipedia.org/wiki/Linear_congruential_generator
# Citation:
# [1] Wikipedia. 2023. Linear congruential generator. Retrieved from https://en.wikipedia.org/wiki/Linear_congruential_generator
# [2] OpenAI. 2024. ChatGPT: AI language model. (October 14, 2024). Retrieved from https://chat.openai.com/.
# Source for the numbers 1664525 and 101304223:
# [3] William H. Press, Saul A. Teukolsky, William T. Vetterling, and Brian P. Flannery. 1992. Numerical Recipes in C: The Art of Scientific Computing (2nd ed.). Cambridge University Press, New York, NY, 308.