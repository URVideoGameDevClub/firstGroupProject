class_name Player
extends CharacterBody2D


## Emitted when player's health is updated
signal player_health_updated(health: int)

## Emitted when player's health is updated to a value <= 0
signal player_death


# These four variables control player movement
# They're set to 0.0 here but set to actual values in ./player.tscn
@export var move_speed = 0.0
@export var acceleration = 0.0
@export var jump_velocity = 0.0
@export var gravity = 0.0
@export var attack_time = 0.0
@export var attack_cooldown = 0.0
@export var attack_damage = 1
@export var health = 5
var can_attack = true
var is_boosting = false
var is_alive = true


# "_inventory" is an array of strings representing the items the player has picked up
# Does not support multiple of the same item type, will change later if we need it
# Please don't access this variable directly from other scripts,
# Instead use the functions below to interact with the inventory
@export var _inventory: Array[String] = []


# Variable holding a reference to the pickup collection area hitbox thing
@onready var pickup_collection_area = get_node("PickupCollectionArea")
@onready var attack_spawner = get_node("AttackSpawner")
@onready var anim_sprite = get_node("AnimatedSprite2D")


func _ready():
	Global.player = self


func _physics_process(delta):
	if not is_alive:
		self.sprite.hide()
		return
	elif position.y > 500.0:
		die()

	var input_axis = Input.get_axis("move_left", "move_right")
	
	# This uses acceleration for smoother movement than just
	# immediately snapping the velocity value to move_speed or something
	velocity.x = move_toward(velocity.x, move_speed * input_axis, acceleration * delta)
	if velocity.x:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")
	
	if input_axis > 0.0:
		anim_sprite.flip_h = true
	elif input_axis < 0.0:
		anim_sprite.flip_h = false
	
	if is_on_floor():
		is_boosting = false
		if Input.is_action_just_pressed("jump"):
			# Negative number because negative y is up btw
			velocity.y = -jump_velocity
			is_boosting = true
	else:
		# Same here, positive number to go down 
		velocity.y += gravity * delta
		if is_boosting:
			if velocity.y > 0.0:
				is_boosting = false
			if Input.is_action_just_released("jump"):
				velocity.y /= 2.5
	
	# Geffen's code: 
	if Input.is_action_just_pressed("attack") && can_attack: 
		attack()
	# end of Geffen's code
	
	# Finally, just let the engine use the player's velocity
	# to move the player and handle collisions
	move_and_slide()


## Apply damage to the player
func damage(damageAmount: int):
	health -= damageAmount
	player_health_updated.emit(health)
	if health <= 0:
		die()
	print("took %d damage, now at %d hp" % [damageAmount, health])


## Die
func die() -> void:
	player_death.emit()
	is_alive = false


# ========== Inventory Functions ========== #

## Returns true if item is in inventory
func has_item(item: String) -> bool:
	return item.to_lower() in _inventory


## Add an item (represented as a string) to the player's inventory
## Returns false if item is already present in player's inventory
func add_item(item: String) -> bool:
	item = item.to_lower()
	# If we already have the item we shouldn't be adding it again,
	# so it'll print out a little debug message and not add it a second time
	if item in _inventory:
		push_warning("%s is already in _inventory" % item)
		return false
	else:
		_inventory.push_back(item)
		return true
# note: maybe we should use a dictionary instead?
# it'd probably be better at pretending to be a hashset


## Clear player inventory
func clear_inventory():
	_inventory.clear()


# Geffen's code
const scene = preload("res://Player/objects/attack_area.tscn")
func attack(): 
	can_attack = false
	if anim_sprite.flip_h:
		attack_spawner.position.x = -30.0
	else:
		attack_spawner.position.x = 30.0
	
	var instance = scene.instantiate()
	instance.set_name("attack_area")
	instance.position = attack_spawner.position;
	add_child(instance)

	await get_tree().create_timer(0.05).timeout

	for collision_body in instance.get_overlapping_bodies():
		if collision_body is BasicEnemy and collision_body.has_method("be_attacked"):
			var knockback_direction := Vector2(float(anim_sprite.flip_h) * 32.0, 16.0)
			collision_body.be_attacked(attack_damage, knockback_direction)
	
	await get_tree().create_timer(attack_time).timeout
	instance.queue_free()
	
	await get_tree().create_timer(attack_cooldown / 2.0).timeout
	can_attack = true
# end of Geffen's code


# When another area enters the pickup collection area,
# if it has the class name "Pickup" we'll add the item name
# to the _inventory and then free the item node that entered us
func _on_pickup_collection_area_entered(area: Area2D):
	if area is Pickup:
		add_item(area.item_name)
		area.queue_free()
		print("Inventory: ", _inventory) # debug print

