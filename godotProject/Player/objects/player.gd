class_name Player
extends CharacterBody2D

@export var move_speed: float
@export var acceleration: float
@export var jump_velocity: float
@export var gravity: float

@export var inventory: Array[String]

var levelno = 1

func _ready():
	print("ready")
	await get_tree().create_timer(.1).timeout
	var doors = get_tree().get_nodes_in_group("door")
	for i in len(doors):
		doors[i].body_entered.connect(touch_door)

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

func touch_door(_body):
	# Waits a tiny bit to maybe fade in and out or whatever we want to do.
	await get_tree().create_timer(.1).timeout
	load_n_unload()
	await get_tree().create_timer(.1).timeout

func load_n_unload():
	# Remove the current level
	var level = get_node("/root/Root/Level1")
	get_node("/root/Root").remove_child(level)
	level.call_deferred("free")
	print("part 1 done")
	
	levelno += 1

# Add the next level
	var next_level_resource = load("res://level" + str(levelno) + ".tscn")
	var next_level = next_level_resource.instantiate()
	get_node("/root/Root").add_child(next_level)
	print("part 2 done")
