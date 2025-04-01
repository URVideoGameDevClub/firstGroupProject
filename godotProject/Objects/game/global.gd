extends Node
## Global signals and a reference to game node. Should not hold any other state.

signal game_entered_tree(game: Game)
signal door_entered(door: Door)
signal enemy_death(enemy: Enemy)
signal player_health_updated(health: int)
signal player_death
signal item_picked_up(item_name: String)
signal spike_hit
signal checkpoint_entered(pos: Vector2)
signal show_crown_anim

# Must NOT be null/freed during gameplay
var _game: Game


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"reload_scene"):
		get_tree().reload_current_scene()


func set_game(game: Game) -> void:
	_game = game


func has_item(item_name: String) -> bool:
	if is_instance_valid(_game) and item_name in _game.inventory:
		return true
	else:
		return false


func is_paused() -> bool:
	return is_instance_valid(_game) and _game.paused


func input_vector() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


