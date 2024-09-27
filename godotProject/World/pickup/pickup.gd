class_name Pickup
extends Area2D

@export var item_name = ""

func get_picked_up():
	queue_free()

func _on_area_entered(area) -> void:
	pass

