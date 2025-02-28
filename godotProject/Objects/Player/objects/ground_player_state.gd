class_name GroundPlayerState
extends PlayerState

const MAX_MOVE_SPEED := 200.0
const ACCEL := 3000.0


func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(
		player.velocity.x,
		Global.input_vector().x * MAX_MOVE_SPEED,
		ACCEL * delta,
	)
	player.move_and_slide()
	
	
