extends Node


@export var current_level: Node2D = null


func _ready() -> void:
	Global.door_entered.connect(_on_door_entered)
	
	if current_level == null:
		push_error("Root.current_level is null")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload_scene"):
		get_tree().reload_current_scene()


func _on_door_entered(door: NewDoor) -> void:
	# Debug
	print(door)
