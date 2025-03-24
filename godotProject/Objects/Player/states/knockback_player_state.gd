class_name KnockbackPlayerState
extends PlayerState


func enter(args: Dictionary[String, Variant] = {}) -> void:
    print(args["direction"])


func physics_update(delta: float) -> void:
    player.transition(player.ground_state)