## Global singleton class, mainly for signals right now
extends Node


signal door_entered(door: NewDoor)
signal enemy_death(enemy: Enemy)
signal player_health_updated(health: int)
signal player_death
signal item_added(item_name: String)
signal spike_hit


var inventory: Array[String] = []


func add_to_inventory(item_name: String) -> void:
	if item_name in inventory:
		push_warning("%s already in inventory" % item_name)
		return
	
	inventory.push_back(item_name)
	item_added.emit(item_name)
