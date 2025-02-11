## Base door class. Emit Global.door_entered(id, target_id) when entered by a player.
class_name NewDoor
extends Node2D


## PackedScene of the room this door leads to
@export var target_room: PackedScene
## The ID of this door.
## Another door with a target_id that matches this door's id will lead to this door.
@export var id := -1
## The ID of the door that this door will lead to.
@export var target_id := -1


## Connect body_entered signals here.
## Will emit Global.door_entered if body is a NewPlayer.
func _on_area_2d_body_entered(body: PhysicsBody2D) -> void:
	if body is NewPlayer:
		Global.door_entered.emit(self)
