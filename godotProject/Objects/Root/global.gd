extends Node
## Global signals and a reference to root. Should not hold any other state.


signal door_entered(door: Door)
signal enemy_death(enemy: Enemy)
signal player_health_updated(health: int)
signal player_death
signal item_picked_up(item_name: String)
signal spike_hit
signal checkpoint_entered(pos: Marker2D)
signal show_crown_anim


var _game: Game
# TODO: move to root
var paused := false

func has_item(item_name: String) -> bool:
	if _game and item_name in _game.inventory:
		return true
	else:
		return false
