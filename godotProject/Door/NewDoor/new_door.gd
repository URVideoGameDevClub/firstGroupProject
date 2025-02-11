## Base door class. Emit Global.door_entered(id, target_id) when entered by a player.
class_name NewDoor
extends Node2D


@export var id := -1
@export var target_id := -1


func _on_area_2d_body_entered(body: PhysicsBody2D) -> void:
	if body is NewPlayer:
		Global.door_entered.emit(self)
