class_name Squirrel
extends Enemy

func takeDamage(damage: int) -> void:
	health -= damage
	
	print("Enemy Health: %d" % health) #for debugging
	
	if health <= 0:
		die()

func die() -> void:
	queue_free()  # Remove enemy from scene
