class_name HurtZone
extends Area2D


@export var damage := 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is NewPlayer:
		body.receive_attack(damage)
		Global.spike_hit.emit()
