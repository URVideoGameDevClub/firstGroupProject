class_name EnemySquirrel
extends CharacterBody2D

enum State {IDLE, WALK, ATTACK, DEATH}

const MOVE_SPEED := 50.0
const IDLE_TIME_MIN := 1.0
const IDLE_TIME_MAX := 3.0
const WALK_TIME_MIN := 3.0
const WALK_TIME_MAX := 5.0
const ATTACK_DAMAGE := 1
const DAMAGE_FLASH_TIME := 0.2

var _state := State.IDLE
var _is_facing_right := false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shader_material: ShaderMaterial = _animated_sprite.material
@onready var _attack_hitbox: Area2D = $AttackHitbox
@onready var _ground_cast_left: RayCast2D = $GroundCastLeft
@onready var _ground_cast_right: RayCast2D = $GroundCastRight


func _ready() -> void:
	_transition(State.IDLE)


func _physics_process(_delta: float) -> void:
	match _state:
		State.IDLE:
			if _get_overlapping_player() != null:
				_transition(State.ATTACK)
		State.WALK:
			if not (_ground_cast_left.is_colliding() or _ground_cast_right.is_colliding()) or is_on_wall():
				_is_facing_right = not _is_facing_right
				_attack_hitbox.position.x = -_attack_hitbox.position.x
				_animated_sprite.flip_h = not _animated_sprite.flip_h

			var dir_x := 1.0 if _is_facing_right else -1.0
			velocity.x = dir_x * MOVE_SPEED
			move_and_slide()
			
			if _get_overlapping_player() != null:
				_transition(State.ATTACK)
		State.ATTACK:
			pass
		State.DEATH:
			pass


func take_attack(_damage: int) -> bool:
	_transition(State.DEATH)
	return true


func _transition(target_state: State) -> void:
	if target_state == _state:
		return
	
	match target_state:
		State.IDLE:
			_animated_sprite.play(&"idle")
			var idle_timer := get_tree().create_timer(randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX))
			idle_timer.timeout.connect(_transition.bind(State.WALK))
		State.WALK:
			_animated_sprite.play(&"walk")
			var walk_timer := get_tree().create_timer(randf_range(WALK_TIME_MIN, WALK_TIME_MAX))
			walk_timer.timeout.connect(_transition.bind(State.IDLE))
		State.ATTACK:
			_animated_sprite.play(&"attack")
		State.DEATH:
			_animated_sprite.play(&"death")
	
	_state = target_state


func _get_overlapping_player() -> Player:
	var bodies := _attack_hitbox.get_overlapping_bodies()
	if bodies.is_empty():
		return null
	
	var body := bodies[0]
	assert(body is Player)
	return body


func _deliver_attack() -> bool:
	var attacked := false

	for body in _attack_hitbox.get_overlapping_bodies():
		if body.has_method(&"take_attack"):
			body.take_attack(ATTACK_DAMAGE)
			attacked = true
	
	return attacked


func _on_animated_sprite_2d_animation_finished() -> void:
	if _animated_sprite.animation == &"attack":
		_transition(State.IDLE)
	elif _animated_sprite.animation == &"death":
		queue_free()


func _on_animated_sprite_2d_frame_changed() -> void:
	if _animated_sprite.animation == &"attack" and _animated_sprite.frame == 4:
		_deliver_attack()
