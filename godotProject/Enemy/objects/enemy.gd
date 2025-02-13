class_name Enemy
extends CharacterBody2D


@export var health := 1:
	set(value):
		health = value
		if value <= 0:
			die()
			Global.enemy_death.emit(self)


func receive_attack(damage: int) -> void:
	health -= damage


func die() -> void:
	print("Ouch! I (%s) am dead." % name)
	queue_free()
