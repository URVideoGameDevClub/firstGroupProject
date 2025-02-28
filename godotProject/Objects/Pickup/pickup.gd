class_name Pickup
extends Area2D

@export var item_name := ""


func _ready() -> void:
	assert(not item_name.is_empty())
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is OldPlayer:
		Global.item_picked_up.emit(item_name)
		queue_free()
