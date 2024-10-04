class_name Player
extends CharacterBody2D

@export var move_speed: float
@export var acceleration: float
@export var jump_velocity: float
@export var gravity: float

@export var inventory: Array[String]

func _physics_process(delta: float) -> void:
	var input_axis: float = Input.get_axis(&"move_left", &"move_right")
	velocity.x = move_toward(velocity.x, move_speed * input_axis, acceleration * delta)
	if is_on_floor():
		if Input.is_action_just_pressed(&"jump"):
			velocity.y = -jump_velocity
	else:
		velocity.y += gravity * delta
	move_and_slide()

func has_item(item: String) -> bool:
	return item.to_lower() in inventory

func add_item(item: String) -> void:
	item = item.to_lower()
	if item in inventory:
		print("%s already in inventory" % item)
	else:
		inventory.push_back(item)

func clear_inventory() -> void:
	inventory.clear()
