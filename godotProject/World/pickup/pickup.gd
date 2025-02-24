class_name Pickup
extends Area2D


@export var item_name := ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is Player:
		Global.add_to_inventory(item_name)
		queue_free()
