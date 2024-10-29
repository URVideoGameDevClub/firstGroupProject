class_name Pickup
extends Area2D

@export var item_name = ""

func _ready():
	# Method to get player might change later tbh -Tenzen
	var player = get_tree().get_nodes_in_group("player")[0]
	# If player already has pickup's name in its inventory, delete pickup -Tenzen
	if player.has_item(item_name):
		queue_free()
		
func get_picked_up():
	queue_free()

func _on_area_entered(area) -> void:
	pass # probably going to delete
