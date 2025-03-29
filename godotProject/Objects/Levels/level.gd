class_name Level
extends Node2D

@export var doors_parent: Node2D

var doors: Array[Door]


func _ready() -> void:
	for door: Door in doors_parent.get_children():
		doors.push_back(door)
