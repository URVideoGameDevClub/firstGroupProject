extends Label


func _ready() -> void:
	hide()
	Global.item_picked_up.connect(_on_item_picked_up)


func _on_item_picked_up(item_name: String) -> void:
	if item_name == "glider":
		show()
