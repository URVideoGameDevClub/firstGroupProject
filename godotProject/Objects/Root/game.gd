class_name Game
extends Node

enum Level { NONE, LEFT, SPAWN, RIGHT }

const LEVELS: Dictionary[Level, String] = {
	Level.NONE: "",
	Level.LEFT: "uid://dcb3cx0bo07it",
	Level.SPAWN: "uid://bnjo3ngrhgibp",
	Level.RIGHT: "",
}
const PLAYER_SCENE := preload("uid://b5qdasw04pvli")

@export var inventory: Array[String]
@export var current_level: Node2D
@export var player: Player

var respawn_point := Vector2.ZERO


func _ready() -> void:
	Global.set_game(self)
	Global.door_entered.connect(_on_door_entered)
	respawn_point = player.global_position


func _on_door_entered(door: Door) -> void:
	_load_level.call_deferred(door)


func _load_level(door: Door) -> void:
	get_tree().paused = true
	
	var target_id := door.target_id
	var new_level_path := LEVELS[door.target_room]
	var new_level: PackedScene = load(new_level_path)
	current_level.queue_free()
	player.queue_free()
	await get_tree().process_frame
	
	current_level = new_level.instantiate()
	add_child(current_level)
	
	var target_door: Door
	for candidate_door: Door in get_tree().get_nodes_in_group(&"door"):
		if candidate_door.id == target_id:
			target_door = candidate_door
			respawn_point = target_door.spawn_marker.global_position
			break
	assert(target_door)
	
	player = PLAYER_SCENE.instantiate()
	player.global_position = respawn_point
	add_child(player)
	
	get_tree().paused = false
