class_name DeathPlayerState
extends PlayerState


func enter() -> void:
	player.animation_state.travel(&"death")
	Global.player_death.emit()
