class_name AirPlayerState
extends PlayerState

const MAX_MOVE_SPEED := 200.0
const MAX_FALL_SPEED := 70.0
const ACCEL := 2000.0
const JUMP_VELOCITY := 400.0
const JUMP_CUTOFF := 2.0
const GRAVITY := 1100.0
const GLIDE_GRAVITY := 600.0
const MAX_GLIDE_FALL_SPEED := 50.0
const JUMP_HOLD_TIME := 0.15
const COYOTE_TIME := 0.05

var gliding := false
var can_jump := false


func enter(args := {}) -> void:
	if args.get("jump"):
		_jump()
	else:
		player.get_tree().create_timer(COYOTE_TIME).timeout.connect(_on_coyote_timer_timeout)
		can_jump = true


func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed(&"jump") and can_jump:
		_jump()
	elif gliding and not Input.is_action_pressed(&"glide"):
		gliding = false
	elif not gliding and Input.is_action_just_pressed(&"glide"):
		gliding = true
	
	player.velocity.x = move_toward(
		player.velocity.x,
		Global.input_vector().x * MAX_MOVE_SPEED,
		ACCEL * delta,
	)
	if gliding:
		player.velocity.y = minf(player.velocity.y + GLIDE_GRAVITY * delta, MAX_GLIDE_FALL_SPEED)
	else:
		player.velocity.y = minf(player.velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	player.move_and_slide()
	
	if player.is_on_floor():
		player.transition(player.ground_state)


func _jump() -> void:
	can_jump = false
	player.velocity.y = -JUMP_VELOCITY
	player.get_tree().create_timer(JUMP_HOLD_TIME).timeout.connect(_on_jump_hold_timer_timeout)


func _on_jump_hold_timer_timeout() -> void:
	if not Input.is_action_pressed(&"jump") and player.velocity.y < 0.0:
		player.velocity.y /= JUMP_CUTOFF


func _on_coyote_timer_timeout() -> void:
	can_jump = false
