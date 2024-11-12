class_name BasicEnemy
extends CharacterBody2D


@export var move_speed = 0.0
@export var acceleration := 0.0
@export var gravity = 0.0
@export var health := 1


var direction = 1.0


# TODO: Make it not just ignore all knockback i send it
func _physics_process(delta):
	if is_on_wall():
		direction *= -1.0

	velocity.x = move_toward(velocity.x, direction * move_speed, delta * acceleration)
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()


# @Override
func receive_attack_damage(damage: int) -> void:
	print("Enemy was attacked for %d damage" % damage)
	health -= damage
	if health <= 0:
		queue_free()
