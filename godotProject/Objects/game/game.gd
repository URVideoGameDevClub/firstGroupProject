class_name Game
extends Node

enum ELevel {NONE, A, B, C}

const LEVELS: Dictionary[ELevel, String] = {
	ELevel.NONE: "",
	ELevel.A: "uid://cif4a0lvh2wti",
	ELevel.B: "uid://w2g2bbasq27b",
	ELevel.C: "uid://bxkkkrbgr5jf1",
}
const PLAYER_SCENE := preload("uid://b5qdasw04pvli")

@export var inventory: Array[String]
@export var current_level: Node2D
@export var player: Player
@export var gui: Gui

var respawn_point := Vector2.ZERO


func _ready() -> void:
	Global.set_game(self)
	Global.door_entered.connect(_on_door_entered)
	Global.item_picked_up.connect(_on_item_picked_up)
	Global.spike_hit.connect(_on_spike_hit)
	Global.checkpoint_entered.connect(_on_checkpoint_entered)
	Global.player_health_updated.emit(player.health)
	respawn_point = player.global_position


func _on_door_entered(door: Door) -> void:
	_load_level_from_door.call_deferred(door)


func _load_level_from_door(door: Door) -> void:
	get_tree().paused = true
	
	gui.anim.play(&"fade_to_black")
	await gui.anim.animation_finished
	
	var target_id := door.target_id
	var new_level_path := LEVELS[door.target_room]
	var new_level: PackedScene = load(new_level_path)
	current_level.queue_free()
	
	current_level = new_level.instantiate()
	add_child(current_level)
	
	var target_door: Door
	for candidate_door: Door in current_level.doors:
		if candidate_door.id == target_id:
			target_door = candidate_door
			respawn_point = target_door.spawn_marker.global_position
			break
	assert(target_door)
	
	get_tree().paused = false
	player.global_position = respawn_point
	await get_tree().process_frame
	player.camera.reset_smoothing()
	
	gui.anim.play_backwards(&"fade_to_black")


func _on_item_picked_up(item_name: String) -> void:
	if item_name in inventory:
		push_warning("%s already in inventory" % item_name)
		return
	
	inventory.push_back(item_name)


func _on_spike_hit() -> void:
	player.accept_damage = false
	gui.anim.play(&"fade_to_black", -1, 2.0)
	await gui.anim.animation_finished
	player.input_frozen = true
	player.global_position = respawn_point
	gui.anim.play(&"fade_to_black", -1, -2.0, true)
	await gui.anim.animation_finished
	player.input_frozen = false
	player.accept_damage = true


func _on_checkpoint_entered(pos: Vector2) -> void:
	respawn_point = pos
