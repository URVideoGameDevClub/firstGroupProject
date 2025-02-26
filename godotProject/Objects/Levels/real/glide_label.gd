extends Label


func _ready() -> void:
	hide()
	Global.item_added.connect(_on_item_added)


func _on_item_added(item_name: String) -> void:
	if item_name == "glider":
		show()
