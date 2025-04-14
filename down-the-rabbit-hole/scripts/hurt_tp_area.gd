class_name HurtTpArea
extends Area2D

@export var damage := 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	(body as Player).take_attack(damage, true)
	Global.hurt_tp_area_entered.emit()
