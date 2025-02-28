class_name GroundPlayerState
extends PlayerState

const MAX_MOVE_SPEED := 200.0
const ACCEL := 3000.0


func enter() -> void:
	pass


func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(
		player.velocity.x,
		Global.input_vector().x * MAX_MOVE_SPEED,
		ACCEL * delta,
	)
	player.move_and_slide()
	player.update_facing()
	
	if player.velocity.x:
		player.animation_state.travel(&"run")
	else:
		player.animation_state.travel(&"idle")
	
	if Input.is_action_just_pressed(&"jump"):
		player.transition(player.air_state)
	elif not player.is_on_floor():
		player.transition(player.air_state)
