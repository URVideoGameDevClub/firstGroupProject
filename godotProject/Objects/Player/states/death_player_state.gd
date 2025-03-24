class_name DeathPlayerState
extends PlayerState


func enter(_args: Dictionary[String, Variant] = {}) -> void:
	player.animation_state.travel(&"death")
	Global.player_death.emit()
