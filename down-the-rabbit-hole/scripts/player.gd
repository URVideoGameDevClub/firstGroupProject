class_name Player
extends CharacterBody2D

enum State {IDLE, RUN, AIR}

const MOVE_SPEED := 200.0
const GROUND_ACCELERATION := 2500.0
const JUMP_VELOCITY := 400.0
const JUMP_VELOCITY_REDUCTION := 3.0
const AIR_ACCELERATION := 2500.0
const AIR_GRAVITY := 1100.0
const GLIDE_GRAVITY := 600.0
const MAX_GLIDE_FALL_SPEED := 60.0

var _state := State.IDLE
var _input_vector := Vector2.ZERO
var _physics_delta := 0.0
var _is_facing_right := false
var _is_jumping_up := false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _attack_hitbox: Area2D = $AttackHitbox


func _ready() -> void:
    _transition(State.IDLE)
    _update_is_facing_right(-1)


func _physics_process(delta: float) -> void:
    _physics_delta = delta
    _input_vector = Vector2(
        Input.get_axis(&"move_left", &"move_right"),
        Input.get_axis(&"move_up", &"move_down"),
    )
    
    var target_state := _state_physics_process(_state)
    
    if target_state != _state:
        _transition(target_state)


func _transition(state: State) -> void:
    _state_exit(_state)
    _state = state
    _state_enter(_state)


func _state_enter(state: State) -> void:
    match state:
        State.IDLE:
            _animation_player.play(&"idle")
        State.RUN:
            _animation_player.play(&"run")
        State.AIR:
            pass


func _state_exit(state: State) -> void:
    match state:
        State.IDLE:
            pass
        State.RUN:
            pass
        State.AIR:
            _is_jumping_up = false


func _state_physics_process(state: State) -> State:
    match state:
        State.IDLE:
            return _idle_state_physics_process()
        State.RUN:
            return _run_state_physics_process()
        State.AIR:
            return _air_state_physics_process()
        _:
            return _state


func _idle_state_physics_process() -> State:
    if is_on_floor() and Input.is_action_just_pressed(&"jump"):
        return _jump()
    if not is_on_floor():
        return State.AIR
    if _input_vector.x:
        return State.RUN
    
    return State.IDLE


func _run_state_physics_process() -> State:
    velocity.x = _horizontal_movement(MOVE_SPEED, GROUND_ACCELERATION)
    move_and_slide()
    _update_is_facing_right(_input_vector.x)

    if is_on_floor() and Input.is_action_just_pressed(&"jump"):
        return _jump()
    if not is_on_floor():
        return State.AIR
    if not (velocity.x or _input_vector.x):
        return State.IDLE
    
    return State.RUN


func _air_state_physics_process() -> State:
    if _is_jumping_up and (not Input.is_action_pressed(&"jump") or velocity.y >= 0):
        velocity.y /= JUMP_VELOCITY_REDUCTION
        _is_jumping_up = false
    
    velocity.x = _horizontal_movement(MOVE_SPEED, AIR_ACCELERATION)
    velocity.y += AIR_GRAVITY * _physics_delta
    move_and_slide()
    _update_is_facing_right(_input_vector.x)

    if is_on_floor():
        return State.IDLE
    
    return State.AIR


func _update_is_facing_right(input_x: float) -> void:
    if _is_facing_right and input_x < 0.0:
        _is_facing_right = false
        _sprite.flip_h = false
        _attack_hitbox.position.x = -abs(_attack_hitbox.position.x)
    elif not _is_facing_right and input_x > 0.0:
        _is_facing_right = true
        _sprite.flip_h = true
        _attack_hitbox.position.x = abs(_attack_hitbox.position.x)


func _horizontal_movement(max_speed: float, accel: float) -> float:
    return move_toward(velocity.x, _input_vector.x * max_speed, accel * _physics_delta)


func _jump() -> State:
    velocity.y = -JUMP_VELOCITY
    _is_jumping_up = true
    _animation_player.play(&"jump_start")
    return State.AIR


func _deliver_attack(damage: int) -> bool:
    var attacked_something := false

    for collider: Node2D in _attack_hitbox.get_overlapping_bodies():
        if collider.has_method(&"take_attack"):
            collider.take_attack(damage)
            attacked_something = true
    
    return attacked_something


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    match _state:
        State.AIR:
            if anim_name == &"jump_start":
                _animation_player.play(&"jump_middle")
