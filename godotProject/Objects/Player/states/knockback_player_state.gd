class_name KnockbackPlayerState
extends PlayerState

const MAX_KNOCKBACK_TIME := 0.5


func enter(args: Dictionary[String, Variant] = {}) -> void:
    print(args["direction"])


func physics_update(delta: float) -> void:
    player.transition(player.ground_state)
