class_name Player
extends CharacterBody2D

# Comments by Tenzen, will add "-Tenzen" everywhere if other people start commenting
# but I got lazy so just assume they're all written by me for now.
# Message me if you have any questions/suggestions/thoughts!!

# These four variables control player movement
# They're set to 0.0 here but set to actual values in ./player.tscn
@export var move_speed = 0.0
@export var acceleration = 0.0
@export var jump_velocity = 0.0
@export var gravity = 0.0
@export var attack_time = 0.0
@export var attack_cooldown = 0.0
var can_attack = true

@export var health = 5

# "inventory" is an array of strings representing the items the player has picked up
# Does not support multiple of the same item type, will change later if we need it
# Please don't access this variable directly in code,
# Instead use the functions below to interact with the inventory
# (Godot please add access specifiers I love encapsulation)
# Btw I added a type specifier to this if u don't know what it is just ignore it,
# it's to make the @export thing work better in the editor
@export var inventory: Array[String] = []

# Variable holding a reference to the pickup collection area hitbox thing
@onready var pickup_collection_area = get_node("PickupCollectionArea")
@onready var animation_player = get_node("AnimationPlayer")
@onready var sprite = get_node("Sprite2D")

func _ready():
	animation_player.play("idle_right")

func _physics_process(delta):
	var input_axis = Input.get_axis("move_left", "move_right")
	
	# This uses acceleration for smoother movement than just
	# immediately snapping the velocity value to move_speed or something
	velocity.x = move_toward(velocity.x, move_speed * input_axis, acceleration * delta)
	
	if input_axis > 0.0:
		sprite.flip_h = false
	elif input_axis < 0.0:
		sprite.flip_h = true
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			# Negative number because negative y is up btw
			velocity.y = -jump_velocity
	else:
		# Same here, positive number to go down 
		velocity.y += gravity * delta
	
	# Geffen's code: 
	if Input.is_action_just_pressed("attack") && can_attack: 
		attack()
	# end of Geffen's code
	
	# Finally, just let the engine use the player's velocity
	# to move the player and handle collisions
	move_and_slide()

# ========== Inventory Functions ========== #

# Takes in a string, returns true if that string is in inventory, otherwise returns false
func has_item(item):
	# I used to_lower() a lot to make stuff case-insensitive
	return item.to_lower() in inventory

# Add an item (represented as a string) to the player's inventory
func add_item(item):
	item = item.to_lower()
	# If we already have the item we shouldn't be adding it again,
	# so it'll print out a little debug message and not add it a second time
	if item in inventory:
		push_warning("%s is already in inventory" % item)
	else:
		inventory.push_back(item)

# Don't think I need to explain this one tbh
func clear_inventory():
	inventory.clear()

# Geffen's code
var scene = preload("res://Player/objects/attack_area.tscn")
func attack(): 
	can_attack = false
	
	var instance = scene.instantiate()
	instance.set_name("attack_area")
	instance.position = get_node("AttackSpawner").position;
	add_child(instance)
	
	await get_tree().create_timer(attack_time).timeout
	instance.queue_free()
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
# end of Geffen's code

# When another area enters the pickup collection area,
# if it has the class name "Pickup" we'll add the item name
# to the inventory and then free the item node that entered us
func _on_pickup_collection_area_entered(area):
	if area is Pickup:
		add_item(area.item_name)
		area.queue_free()
		print("Inventory: ", inventory) # debug print

func damage(damageAmount):
	health -= damageAmount
	print("took %d damage, now at %d hp" % [damageAmount, health])
