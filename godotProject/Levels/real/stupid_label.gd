extends Label


func _ready() -> void:
	if "glider" in Global.inventory:
		queue_free()
