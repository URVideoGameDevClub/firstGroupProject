class_name Game
extends Node

enum Level { NONE, SPAWN, LEFT, RIGHT }

const PLAYER_SCENE := preload("uid://bo7ruckc5q446")
const CROWN_ANIM_SCENE := preload("uid://fb5owoxxidir")
const THANK_YOU_SCENE := preload("uid://cqay4eu5nq4kd")
const LEVELS := {
	Level.NONE: null,
	Level.SPAWN: preload("uid://bnjo3ngrhgibp"),
	Level.LEFT: preload("uid://dcb3cx0bo07it"),
}

@export var current_level: Node2D
@export var last_spawn_marker: Marker2D
@export var player: Player
@export var inventory: Array[String]


func _enter_tree() -> void:
	Global._game = self


func _ready() -> void:
	Global.door_entered.connect(_on_door_entered)
	Global.spike_hit.connect(_on_spike_hit)
	Global.checkpoint_entered.connect(_on_checkpoint_entered)
	Global.show_crown_anim.connect(_on_show_crown_anim)
	Global.player_death.connect(_on_player_death)
	Global.item_picked_up.connect(_add_to_inventory)
	
	if current_level == null:
		push_error("Root.current_level is null")


func _add_to_inventory(item_name: String) -> void:
	if item_name in inventory:
		push_warning("%s already present in inventory" % item_name)
	
	inventory.push_back(item_name)


# TODO: CHANGE ALL OF THIS
func _on_door_entered(door: Door) -> void:
	if door.id == 2:
		Global.paused = true
		player.visible = false
		var thank_you := THANK_YOU_SCENE.instantiate()
		add_child(thank_you)
		thank_you.get_node("AnimationPlayer").play(&"new_animation")
		return
	
	current_level.queue_free()
	print(door.target_room)
	current_level = LEVELS[door.target_room].instantiate()
	add_child.call_deferred(current_level)
	var target_id := door.target_id
	await get_tree().process_frame
	for i_door: Door in get_tree().get_nodes_in_group(&"door"):
		if i_door.id == target_id:
			last_spawn_marker = i_door.spawn_marker
			player.global_position = last_spawn_marker.global_position


func _on_spike_hit() -> void:
	player.global_position = last_spawn_marker.global_position


func _on_checkpoint_entered(marker: Marker2D) -> void:
	last_spawn_marker = marker


func _on_show_crown_anim() -> void:
	Global.paused = true
	if player.state == Player.State.RUN:
		player.set_state(Player.State.IDLE)
	player.sprite.pause()
	var crown_anim := CROWN_ANIM_SCENE.instantiate()
	add_child(crown_anim)
	crown_anim.get_node("AnimationPlayer").play(&"the_anim")
	await crown_anim.get_node("AnimationPlayer").animation_finished
	Global.paused = false
	crown_anim.queue_free()
	player.sprite.play()


func _on_player_death() -> void:
	await get_tree().create_timer(2.0).timeout
	player.health = 3
	Global.player_health_updated.emit(player.health)
	player.global_position = last_spawn_marker.global_position
	player.velocity.y = 0.0
	print(player.global_position)
	print(last_spawn_marker.global_position)
	player.set_state(Player.State.IDLE)
