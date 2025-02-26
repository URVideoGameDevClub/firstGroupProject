extends Area2D

@export var speed = 100
var blowing = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		blowing = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		blowing = false
