class_name NewPlayer
extends CharacterBody2D


enum State { IDLE, RUN, AIR, ATTACK, DEATH }


const DAMAGE_ANIM_TIME := 0.2


@export var move_speed: float
@export var jump_velocity: float
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var low_gravity_multiplier := 0.75
@export var wall_max_fall_speed := 64.0
@export var health := 3
@export var max_health := 3
@export var attack_damage := 1
@export var debug_log := false


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shader_material: ShaderMaterial = sprite.material
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var wall_cast: RayCast2D = $WallCast
@onready var wall_cast_length: float = wall_cast.target_position.length()
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


var state := State.IDLE
var input_vector := Vector2.ZERO
var this_delta := 0.0
var jump_animation_in_progress := false
var land_animation_in_progress := false
var jump_held := false
var last_wall_normal_x := 0.0
var can_jump := true


## Set player state. Optional second argument is a dictionary used to configure the state transition.
func set_state(value: State, opts := {}) -> void:
	if debug_log:
		print("Player state: %s -> %s" % [state_to_string(state), state_to_string(value)])
	
	jump_animation_in_progress = false
	land_animation_in_progress = false
	jump_held = false
	
	if value == State.AIR and "jump" in opts and opts["jump"] == true:
		velocity.y = -jump_velocity
		jump_animation_in_progress = true
		jump_held = true
		sprite.play(&"air_start")
	elif "land" in opts and opts["land"] == true:
		land_animation_in_progress = true
		sprite.play(&"air_finish")
	elif value == State.ATTACK:
		sprite.play(&"attack")
		_send_attacks()
	elif value == State.IDLE or value == State.RUN:
		can_jump = true
	elif value == State.DEATH:
		sprite.play(&"death")
		collision_shape.disabled = true
	
	state = value


static func state_to_string(s: State) -> String:
	match s:
		State.IDLE:
			return "IDLE"
		State.RUN:
			return "RUN"
		State.AIR:
			return "AIR"
		State.ATTACK:
			return "ATTACK"
		State.DEATH:
			return "DEATH"
		_:
			return "INVALID STATE '%s'" % s


func _ready() -> void:
	Global.player_health_updated.emit(health)


func _physics_process(delta: float) -> void:
	input_vector = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	wall_cast.target_position.x = sign(input_vector.x) * wall_cast_length
	this_delta = delta
	
	if input_vector.x > 0.0:
		sprite.flip_h = true
		attack_hitbox.position.x = abs(attack_hitbox.position.x)
	elif input_vector.x < 0.0:
		sprite.flip_h = false
		attack_hitbox.position.x = -abs(attack_hitbox.position.x)
	
	if is_on_wall():
		last_wall_normal_x = get_last_slide_collision().get_normal().x
	
	match state:
		State.IDLE:
			_idle_state()
		State.RUN:
			_run_state()
		State.AIR:
			_air_state()
		State.ATTACK:
			_attack_state()
		State.DEATH:
			_death_state()
		_:
			push_error("Invalid player state %d" % state)


func _idle_state() -> void:
	can_jump = true
	velocity.x = 0.0
	move_and_slide()
	
	if not land_animation_in_progress:
		sprite.play(&"idle")
	
	if Input.is_action_just_pressed(&"attack"):
		set_state(State.ATTACK)
	elif _get_jump():
		can_jump = false
		set_state(State.AIR, {"jump": true})
	elif not is_on_floor():
		set_state(State.AIR)
	elif input_vector.x != 0.0:
		set_state(State.RUN)


func _run_state() -> void:
	can_jump = true
	velocity.x = input_vector.x * move_speed
	move_and_slide()
	
	sprite.play(&"run")
	
	if Input.is_action_just_pressed(&"attack"):
		set_state(State.ATTACK)
	elif _get_jump():
		can_jump = false
		set_state(State.AIR, {"jump": true})
	elif not is_on_floor():
		set_state(State.AIR)
	elif velocity.x == 0.0:
		set_state(State.IDLE)


func _air_state() -> void:
	coyote_timer.start()
	if _get_jump():
		can_jump = false
		set_state(State.AIR, {"jump": true})
	elif Input.is_action_just_released(&"jump") or velocity.y >= 0.0:
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


func _attack_state() -> void:
	pass


func _send_attacks() -> void:
	for body: Node2D in attack_hitbox.get_overlapping_bodies():
		# TODO: Change to use new Enemy class
		if body is Enemy:
			body.receive_attack(attack_damage)


func _death_state() -> void:
	pass


func _get_jump() -> bool:
	if is_on_floor():
		return Input.is_action_just_pressed(&"jump") and can_jump
	else:
		return Input.is_action_pressed(&"jump") and can_jump


func receive_attack(damage: int) -> void:
	print("Player health: %d -> %d" % [health, health - damage])
	health = maxi(health - damage, 0)
	Global.player_health_updated.emit(health)
	
	if health == 0:
		set_state.call_deferred(State.DEATH)
	else:
		shader_material.set_shader_parameter(&"is_damage_state", true)
		await get_tree().create_timer(DAMAGE_ANIM_TIME).timeout
		shader_material.set_shader_parameter(&"is_damage_state", false)


# Signal callbacks
func _on_sprite_animation_finished() -> void:
	# TODO: Change this to a match statement?
	if sprite.animation == &"air_start":
		jump_animation_in_progress = false
	elif sprite.animation == &"air_finish":
		land_animation_in_progress = false
	elif sprite.animation == &"attack":
		set_state(State.IDLE)


func _on_coyote_timer_timeout() -> void:
	can_jump = false
