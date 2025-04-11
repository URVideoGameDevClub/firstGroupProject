class_name Level
extends Node2D

@export var _middleground_tiles: TileMapLayer
@export var _door_container: Node2D


func get_doors() -> Array[Door]:
	var doors: Array[Door]
	doors.assign(_door_container.get_children())
	return doors
