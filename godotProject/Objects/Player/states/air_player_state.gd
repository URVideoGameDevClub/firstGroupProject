class_name AirPlayerState
extends PlayerState

const MAX_MOVE_SPEED := 200.0
const MAX_FALL_SPEED := 500.0
const ACCEL := 2000.0
const JUMP_VELOCITY := 400.0
const JUMP_CUTOFF := 3.0
const GRAVITY := 1100.0
const GLIDE_GRAVITY := 600.0
const MAX_GLIDE_FALL_SPEED := 60.0
const COYOTE_TIME := 0.15

var gliding := false
var jump_held := false
var coyote_time := 0.0
var jumps_remaining := 0


func enter() -> void:
	jumps_remaining = player.jump_count
	if Input.is_action_just_pressed(&"jump"):
		_jump()
	else:
		player.animation_state.travel(&"jump_middle")
		coyote_time = COYOTE_TIME


func exit() -> void:
	gliding = false
	jump_held = false
	coyote_time = 0.0


func physics_update(delta: float) -> void:
	coyote_time = maxf(coyote_time - delta, 0.0)
	
	if (coyote_time > 0.0 or jumps_remaining > 0) and Input.is_action_just_pressed(&"jump"):
		_jump()
	elif gliding and not Input.is_action_pressed(&"glide"):
		gliding = false
		match player.animation_state.get_current_node():
			&"glide_start":
				player.animation_state.travel(&"jump_start")
			&"glide_middle":
				player.animation_state.travel(&"jump_middle")
	elif not gliding and player.glide_enabled and Input.is_action_pressed(&"glide"):
		gliding = true
		match player.animation_state.get_current_node():
			&"jump_start":
				player.animation_state.travel(&"glide_start")
			&"jump_middle":
				player.animation_state.travel(&"glide_middle")
	
	player.velocity.x = move_toward(
		player.velocity.x,
		Global.input_vector().x * MAX_MOVE_SPEED,
		ACCEL * delta,
	)
	if gliding and player.velocity.y > 0.0:
		player.velocity.y = minf(player.velocity.y + GLIDE_GRAVITY * delta, MAX_GLIDE_FALL_SPEED)
	else:
		player.velocity.y = minf(player.velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
		if jump_held and Input.is_action_just_released(&"jump") and player.velocity.y < 0.0:
			jump_held = false
			player.velocity.y /= JUMP_CUTOFF
	player.move_and_slide()
	player.update_facing()
	
	if player.is_on_floor():
		player.transition(player.ground_state)


func _jump() -> void:
	if jumps_remaining <= 0:
		return
	
	jumps_remaining -= 1
	coyote_time = 0.0
	jump_held = true
	player.velocity.y = -JUMP_VELOCITY
	if gliding:
		player.animation_state.start(&"glide_start")
	else:
		player.animation_state.start(&"jump_start")
