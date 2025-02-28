class_name PlayerState
extends RefCounted


var player: Player


func _init(p_player: Player) -> void:
	player = p_player


func enter(_args := {}) -> void:
	pass


func exit() -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
