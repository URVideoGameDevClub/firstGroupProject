class_name OldPlayer
extends CharacterBody2D

enum State { IDLE, RUN, AIR, ATTACK, DEATH, GLIDE }

const MOVE_SPEED := 200.0
const GROUND_ACCEL := 3000.0
const AIR_ACCEL := 2000.0
const JUMP_VELOCITY := 400.0
const GRAVITY := 1100.0
const JUMP_CUTOFF := 0.5
const MAX_FALL_SPEED := 70.0
const GLIDE_GRAVITY := 600.0
const GLIDE_MAX_FALL_SPEED := 50.0
const LOW_GRAVITY_MULTIPLIER := 0.75
const ATTACK_DAMAGE := 1
const DAMAGE_ANIM_TIME := 0.2

@export var health := 3:
	set(value):
		health = value
		Global.player_health_updated.emit(value)
@export var debug_log := false

var state := State.IDLE
var input_vector := Vector2.ZERO
var phys_delta := 0.0
var jump_animation_in_progress := false
var land_animation_in_progress := false
var jump_held := false
var can_jump := true
var invincible := false
var gravity := GRAVITY
var double_attack_queued := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shader_material: ShaderMaterial = sprite.material
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var jump_hold_timer: Timer = $JumpHoldTimer


## Set player state. Optional second argument is a dictionary used to configure the state transition.
func set_state(value: State, opts := {}) -> void:
	if debug_log:
		print("Player state: %s -> %s" % [state_to_string(state), state_to_string(value)])
	
	jump_hold_timer.stop()
	jump_animation_in_progress = false
	land_animation_in_progress = false
	jump_held = false
	gravity = GRAVITY
	double_attack_queued = false
	
	if state == State.DEATH:
		collision_shape.disabled = false
	
	if value == State.AIR and opts.get("jump"):
		velocity.y = -JUMP_VELOCITY
		jump_animation_in_progress = true
		jump_held = true
		sprite.play(&"air_start")
		jump_hold_timer.start()
	elif opts.get("land"):
		land_animation_in_progress = true
		sprite.play(&"air_finish")
	elif value == State.ATTACK:
		sprite.play(&"attack")
	elif value == State.IDLE or value == State.RUN:
		can_jump = true
	elif value == State.DEATH:
		sprite.play(&"death")
		collision_shape.disabled = true
	elif value == State.GLIDE:
		sprite.play(&"glide_start")
	if value == State.IDLE and state == State.GLIDE:
		sprite.play(&"glide_end")
		land_animation_in_progress = true
	
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
		State.GLIDE:
			return "GLIDE"
		_:
			return "INVALID STATE '%s'" % s


func _ready() -> void:
	Global.player_health_updated.emit(health)
	Global.door_entered.connect(_on_door_entered)


func _physics_process(delta: float) -> void:
	if Global.is_paused():
		return
	
	input_vector = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	phys_delta = delta
	
	if input_vector.x > 0.0:
		sprite.flip_h = true
		attack_hitbox.position.x = absf(attack_hitbox.position.x)
	elif input_vector.x < 0.0:
		sprite.flip_h = false
		attack_hitbox.position.x = -absf(attack_hitbox.position.x)
	
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
		State.GLIDE:
			_glide_state()
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
	velocity.x = move_toward(velocity.x, input_vector.x * MOVE_SPEED, GROUND_ACCEL * phys_delta)
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
		return
	elif Input.is_action_just_pressed(&"glide") and Global.has_item("glider"):
		set_state(State.GLIDE)
		return
	
	velocity.x = move_toward(velocity.x, input_vector.x * MOVE_SPEED, AIR_ACCEL * phys_delta)
	if Input.is_action_just_released(&"jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUTOFF
	velocity.y += gravity * phys_delta
	move_and_slide()
	
	if not jump_animation_in_progress:
		if velocity.y < 0.0:
			sprite.play(&"air_ascending")
		else:
			sprite.play(&"air_descending")
	
	if is_on_floor() and velocity.y >= 0.0:
		set_state(_ground_transition(), {"land": true})


func _attack_state() -> void:
	if Input.is_action_just_pressed(&"attack") and sprite.frame > 0:
		double_attack_queued = true


func _send_attacks() -> void:
	for body: Node2D in attack_hitbox.get_overlapping_bodies():
		if body is Enemy:
			body.receive_attack(ATTACK_DAMAGE)


func _death_state() -> void:
	pass


func _glide_state() -> void:
	velocity.x = input_vector.x * MOVE_SPEED
	velocity.y = minf(velocity.y + GLIDE_GRAVITY * phys_delta, GLIDE_MAX_FALL_SPEED)
	move_and_slide()
	
	if is_on_floor():
		set_state(State.IDLE)
	elif not Input.is_action_pressed(&"glide"):
		set_state(State.AIR)


func _get_jump() -> bool:
	if is_on_floor():
		return Input.is_action_just_pressed(&"jump") and can_jump
	else:
		return Input.is_action_pressed(&"jump") and can_jump


func _ground_transition() -> State:
	if velocity.x == 0.0:
		return State.IDLE
	else:
		return State.RUN


func receive_attack(damage: int) -> void:
	if invincible:
		return
	
	if debug_log:
		print("Player health: %d -> %d" % [health, health - damage])
	
	health = maxi(health - damage, 0)
	Global.player_health_updated.emit(health)
	invincible = true
	invincibility_timer.start()
	
	if health == 0:
		set_state.call_deferred(State.DEATH)
		Global.player_death.emit()
	else:
		shader_material.set_shader_parameter(&"is_damage_state", true)
		await get_tree().create_timer(DAMAGE_ANIM_TIME).timeout
		shader_material.set_shader_parameter(&"is_damage_state", false)


# Signal callbacks
func _on_sprite_animation_finished() -> void:
	# TODO: Change this to a match statement?
	match sprite.animation:
		&"air_start":
			jump_animation_in_progress = false
		&"air_finish", &"glide_finish":
			land_animation_in_progress = false
		&"attack":
			# temp disable
			if double_attack_queued and false:
				sprite.play(&"double_attack")
				double_attack_queued = false
			else:
				set_state(State.IDLE)
		&"double_attack":
			set_state(State.IDLE)
		&"glide_start":
			if state == State.GLIDE:
				sprite.play(&"glide_middle")


func _on_coyote_timer_timeout() -> void:
	can_jump = false


func _on_invincibility_timer_timeout() -> void:
	invincible = false


func _on_animated_sprite_2d_frame_changed() -> void:
	if state == State.ATTACK:
		if sprite.frame == 2:
			_send_attacks()


func _on_jump_hold_timer_timeout() -> void:
	pass


func _on_door_entered(_door: Door) -> void:
	set_state(State.IDLE)
