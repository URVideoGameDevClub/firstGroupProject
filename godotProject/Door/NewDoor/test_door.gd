extends NewDoor


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is NewPlayer:
		Global.door_entered.emit(self)
