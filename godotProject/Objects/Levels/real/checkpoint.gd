extends Area2D

@onready var marker: Marker2D = $Marker2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.checkpoint_entered.emit(marker.global_position)
