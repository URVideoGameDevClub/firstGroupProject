extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is NewPlayer:
		Global.checkpoint_entered.emit($Marker2D)
