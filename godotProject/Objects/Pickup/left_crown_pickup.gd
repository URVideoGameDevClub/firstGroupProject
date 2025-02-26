extends Pickup


func _ready() -> void:
	body_entered.connect(lol)


func lol(body: Node2D) -> void:
	if body is Player:
		Global.show_crown_anim.emit()
