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

# "inventory" is an array of strings representing the items the player has picked up
# Does not support multiple of the same item type, will change later if we need it
# Please don't access this variable directly in code,
# Instead use the functions below to interact with the inventory
# (Godot please add access specifiers I love encapsulation)
@export var inventory = []

func _physics_process(delta):
	var input_axis = Input.get_axis("move_left", "move_right")
	
	# This uses acceleration for smoother movement than just
	# immediately snapping the velocity value to move_speed or something
	velocity.x = move_toward(velocity.x, move_speed * input_axis, acceleration * delta)

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			# Negative number because negative y is up btw
			velocity.y = -jump_velocity
	else:
		# Same here, positive number to go down 
		velocity.y += gravity * delta
	
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

# Don't think I need to explain this one
func clear_inventory():
	inventory.clear()
