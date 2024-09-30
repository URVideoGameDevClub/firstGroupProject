class_name BasicEnemy
extends CharacterBody2D

@export var move_speed = 0.0
@export var gravity = 0.0

var direction = 1.0

func _physics_process(delta):
	if is_on_wall():
		direction *= -1.0
	velocity.x = direction * move_speed
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
