class_name HurtZone
extends Area2D

@export var damage := 1
@export var knock_up := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var knockback_direction := Vector2.ZERO
		if knock_up:
			knockback_direction = Vector2.UP.rotated(randf_range(-PI / 4.0, PI / 4.0))
		body.receive_attack(damage, knockback_direction)
		Global.spike_hit.emit()
