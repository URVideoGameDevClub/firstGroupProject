class_name NewPlayer
extends CharacterBody2D


enum State { IDLE, RUN, AIR }


@export var move_speed: float
@export var jump_velocity: float
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var low_gravity_multiplier := 0.75
@export var attack_damage := 1


@onready var sprite := $AnimatedSprite2D
@onready var attack_hitbox := $AttackHitbox


var state := State.IDLE
var input_vector := Vector2.ZERO
## Member variable delta so I don't have to pass it everywhere
var this_delta := 0.0
var jump_animation_in_progress := false
var land_animation_in_progress := false
var jump_held := false


func _physics_process(delta: float) -> void:
	input_vector = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	this_delta = delta

	if input_vector.x > 0.0:
		sprite.flip_h = true
		attack_hitbox.position.x = abs(attack_hitbox.position.x)
	elif input_vector.x < 0.0:
		sprite.flip_h = false
		attack_hitbox.position.x = -abs(attack_hitbox.position.x)
	
	if Input.is_action_just_pressed(&"attack"):
		_send_attacks()
		# Note: remove this later and turn it into a real state. This is just for debugging.

	match state:
		State.IDLE:
			_idle()
		State.RUN:
			_run()
		State.AIR:
			_air()
		_:
			push_error("Invalid player state %d" % state)


# I've been preferring explicit getters/setters like this one tbh
## Set player state. Optional second argument is a dictionary used to configure the state transition.
func set_state(value: State, opts := {}) -> void:
	jump_animation_in_progress = false
	land_animation_in_progress = false
	jump_held = false

	if value == State.AIR:
		if "jump" in opts and opts["jump"] == true:
			velocity.y = -jump_velocity
			jump_animation_in_progress = true
			jump_held = true
			sprite.play(&"air_start")
	else:
		if "land" in opts and opts["land"] == true:
			land_animation_in_progress = true
			sprite.play(&"air_finish")

	state = value


func _idle() -> void:
	velocity.x = 0.0
	move_and_slide()

	if not land_animation_in_progress:
		sprite.play(&"idle")

	if Input.is_action_just_pressed(&"jump"):
		set_state(State.AIR, {"jump": true})
	elif not is_on_floor():
		set_state(State.AIR)
	elif input_vector.x != 0.0:
		set_state(State.RUN)


func _run() -> void:
	velocity.x = input_vector.x * move_speed
	move_and_slide()

	sprite.play(&"run")

	if Input.is_action_just_pressed(&"jump"):
		set_state(State.AIR, {"jump": true})
	elif not is_on_floor():
		set_state(State.AIR)
	elif velocity.x == 0.0:
		set_state(State.IDLE)


func _air() -> void:
	if Input.is_action_just_released(&"jump") or velocity.y >= 0.0:
		jump_held = false
	
	var local_gravity := gravity
	if jump_held == true:
		local_gravity *= low_gravity_multiplier

	velocity.x = input_vector.x * move_speed
	velocity.y += local_gravity * this_delta
	move_and_slide()

	if not jump_animation_in_progress:
		if velocity.y < 0.0:
			sprite.play(&"air_ascending")
		else:
			sprite.play(&"air_descending")

	if is_on_floor() and velocity.y >= 0.0:
		set_state(State.IDLE, {"land": true})


func _send_attacks() -> void:
	for potential_opp in attack_hitbox.get_overlapping_bodies():
		if potential_opp is BasicEnemy:
			print("Enemy Attacked")


func _on_sprite_animation_finished() -> void:
	if sprite.animation == &"air_start":
		jump_animation_in_progress = false
	elif sprite.animation == &"air_finish":
		land_animation_in_progress = false