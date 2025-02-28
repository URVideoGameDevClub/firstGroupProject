extends Label


func _ready() -> void:
	if Global.has_item("glider"):
		queue_free()
