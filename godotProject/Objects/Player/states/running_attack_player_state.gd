class_name RunningAttackPlayerState
extends PlayerState

const MAX_MOVE_SPEED := 200.0


func enter(_args: Dictionary[String, Variant] = {}) -> void:
	player.animation_state.travel(&"running_attack")
	player.velocity.x = signf(player.velocity.x) * MAX_MOVE_SPEED


func physics_update(delta: float) -> void:
	player.move_and_slide()

	if signf(Global.input_vector().x) != signf(player.velocity.x):
		player.transition(player.ground_state)
		player.animation_state.start(&"idle")
