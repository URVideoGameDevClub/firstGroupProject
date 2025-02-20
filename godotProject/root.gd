extends Node


const PLAYER_SCENE := preload("res://Player/objects/new_player.gd")


@export var current_level: Node2D
@export var last_door: NewDoor
@export var player: NewPlayer


func _ready() -> void:
	Global.door_entered.connect(_on_door_entered)
	Global.spike_hit.connect(_on_spike_hit)
	
	if current_level == null:
		push_error("Root.current_level is null")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload_scene"):
		get_tree().reload_current_scene()


func _on_door_entered(door: NewDoor) -> void:
	# Debug
	print(door)
	
	current_level.queue_free()
	current_level = door.target_room.instantiate()
	add_child(current_level)
	
	print("WIP - Spawn new player in level")
	# instantiate new player, set player.global_position = door.spawn_marker.global_position
	# add player as child of level probably


func _on_spike_hit() -> void:
	player.global_position = last_door.spawn_marker.global_position
