class_name AirPlayerState
extends PlayerState

const MAX_MOVE_SPEED := 200.0
const MAX_FALL_SPEED := 500.0
const ACCEL := 2000.0
const JUMP_VELOCITY := 400.0
const JUMP_CUTOFF := 3.0
const GRAVITY := 1100.0
const GLIDE_GRAVITY := 600.0
const MAX_GLIDE_FALL_SPEED := 50.0
const JUMP_HOLD_TIME := 0.1
const COYOTE_TIME := 0.05

var gliding := false
var can_jump := false
var jump_held := false


func enter() -> void:
	gliding = false
	can_jump = false
	jump_held = false
	
	if Input.is_action_just_pressed(&"jump"):
		_jump()
	else:
		player.get_tree().create_timer(COYOTE_TIME).timeout.connect(_on_coyote_timer_timeout)
		can_jump = true


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	if gliding and not Input.is_action_pressed(&"glide"):
		gliding = false
		match player.animation_state.get_current_node():
			&"glide_start":
				player.animation_state.travel(&"jump_start")
			&"glide_middle":
				player.animation_state.travel(&"jump_middle")
	elif not gliding and Input.is_action_pressed(&"glide"):
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
	if gliding:
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
	can_jump = false
	jump_held = true
	player.velocity.y = -JUMP_VELOCITY
	player.animation_state.travel(&"jump_start")


func _on_coyote_timer_timeout() -> void:
	can_jump = false
