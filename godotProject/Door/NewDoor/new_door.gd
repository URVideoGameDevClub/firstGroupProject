## Base door class. Emit Global.door_entered(id, target_id) when entered by a player.
class_name NewDoor
extends Node2D


## PackedScene of the room this door leads to.
@export var target_room: PackedScene = null

## Area2D to detect player entering the door.
@export var area: Area2D = null

## Marker of the position that the player will spawn when they come through this door.
@export var spawn_marker: Marker2D = null

## The ID of this door.
## Another door with a target_id that matches this door's id will lead to this door.
## Be sure to change this from the default -1. Pushes error if you forget :)
@export var id := -1

## The ID of the door that this door will lead to.
## Default value of -1 will give an error, so don't forget to change it to the value you want.
@export var target_id := -1


func _ready() -> void:
	if area == null:
		push_error("area is null")
	if target_room == null:
		push_error("target_room is null")
	if spawn_marker == null:
		push_error("spawn_marker is null")
	if id < 0:
		push_error("id == %d < 0, please change from default" % id)
	if target_id < 0:
		push_error("target_id == %d < 0, please change from default" % target_id)
	
	if not area.body_entered.is_connected(_on_area_2d_body_entered):
		area.body_entered.connect(_on_area_2d_body_entered)


## Connect body_entered signals here.
## Will emit Global.door_entered if body is a NewPlayer.
func _on_area_2d_body_entered(body: PhysicsBody2D) -> void:
	if body is NewPlayer:
		Global.door_entered.emit(self)


func _to_string() -> String:
	return "NewDoor { target_room: %s, id: %d, target_id: %d }" % [target_room, id, target_id]
