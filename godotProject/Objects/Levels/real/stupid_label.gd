extends Label


func _ready() -> void:
	if Global.root.has_item("glider"):
		queue_free()
