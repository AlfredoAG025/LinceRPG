extends CharacterBody2D

# vars
@export var walk_speed = 4.0
const TILE_SIZE = 16

# animations
@onready var animation_tree = $AnimationTree
@onready var anim_state = animation_tree.get("parameters/playback")
@onready var animation_player = $AnimationPlayer

# raycast
@onready var ray_cast_2d = $RayCast2D


# States
enum PlayerState {IDLE, TURNING, WALKING}
# Directions
enum facingDirection {LEFT, RIGHT, UP, DOWN}

# Default state & direction
var player_state = PlayerState.IDLE
var facing_direction = facingDirection.DOWN


# player position
var initial_position = Vector2.ZERO
var input_direction = Vector2.ZERO
var is_moving = false
var percent_moved_to_next_tile = 0.0

func _ready():
	animation_tree.active = true # activate the animation_tree
	initial_position = position

# called every frame
func _physics_process(delta):
	if player_state == PlayerState.TURNING:
		return
	elif is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk") # We change from Idle to Walk
		move(delta)
	else:
		anim_state.travel("Idle") # We change from Walk to Idle
		is_moving = false

func process_player_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	if input_direction != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_direction) # Change the direction value in blendspace 
		animation_tree.set("parameters/Walk/blend_position", input_direction) # Change the direction value in blendspace 
		animation_tree.set("parameters/Turn/blend_position", input_direction) # Change the direction value in blendspace 
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel("Turn")
			await animation_tree.animation_finished # Waiting for animation finished
			player_state = PlayerState.IDLE # change to IDLE
		else:
			initial_position = position
			is_moving = true
	else:
		anim_state.travel("Idle") # We change from Walk to Idle

func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = facingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = facingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = facingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = facingDirection.DOWN
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction
	return false

func move(delta):
	percent_moved_to_next_tile += walk_speed * delta
	# Vector2 of the Next tile
	var desired_step = input_direction * TILE_SIZE / 2
	ray_cast_2d.target_position = desired_step
	ray_cast_2d.force_raycast_update()
	if !ray_cast_2d.is_colliding():
		if percent_moved_to_next_tile  >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	else:
		percent_moved_to_next_tile = 0.0
		is_moving = false
