extends Node


func _ready() -> void:
	Global.door_entered.connect(_on_door_entered)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload_scene"):
		get_tree().reload_current_scene()


func _on_door_entered(door: NewDoor) -> void:
	if door.id < 0:
		push_error("Invalid door id: %d. Remember to change the defaults." % door.id)
	if door.target_id < 0:
		push_error("Invalid door target_id: %d. Remember to change the defaults" % door.target_id)
	print(door)
