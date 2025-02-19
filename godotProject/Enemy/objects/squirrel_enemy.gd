class_name SquirrelEnemy
extends Enemy

enum State { IDLE, WALK, ATTACK }

const IDLE_TIME_MIN := 1.0
const IDLE_TIME_MAX := 3.0
const WALK_TIME_MIN := 3.0
const WALK_TIME_MAX := 5.0
const WALK_SPEED := 50.0
const ATTACK_DAMAGE := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var ground_cast_l: RayCast2D = $GroundCastL
@onready var ground_cast_r: RayCast2D = $GroundCastR
@onready var vision_cast: RayCast2D = $VisionCast
@onready var hitbox: Area2D = $Hitbox
@onready var shader_material: ShaderMaterial = sprite.material

@onready var facing_right := sprite.flip_h

var state := State.IDLE


func _ready() -> void:
	set_state(State.IDLE)
	set_facing_right(facing_right)


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			var collider := vision_cast.get_collider()
			if collider and collider is NewPlayer:
				set_state(State.ATTACK)
		State.WALK:
			var collider := vision_cast.get_collider()
			if collider and collider is NewPlayer:
				set_state(State.ATTACK)
				return
			
			if facing_right and not ground_cast_r.is_colliding():
				set_facing_right(false)
			elif not facing_right and not ground_cast_l.is_colliding():
				set_facing_right(true)
			velocity.x = WALK_SPEED * (1.0 if facing_right else -1.0)
			move_and_slide()
		State.ATTACK:
			pass


func set_facing_right(value: bool) -> void:
	facing_right = value
	sprite.flip_h = value
	vision_cast.target_position.x = abs(vision_cast.target_position.x) * (1.0 if facing_right else -1.0)
	hitbox.position.x = abs(hitbox.position.x) * (1.0 if facing_right else -1.0)


func set_state(value: State) -> void:
	match value:
		State.IDLE:
			sprite.play(&"idle")
			timer.start(randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX))
		State.WALK:
			sprite.play(&"walk")
			timer.start(randf_range(WALK_TIME_MIN, WALK_TIME_MAX))
			set_facing_right(randi() % 2 == 0)
		State.ATTACK:
			timer.stop()
			sprite.play(&"attack")
	
	hitbox.monitoring = false
	state = value


func receive_attack(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		set_state(State.IDLE)
	
	shader_material.set_shader_parameter(&"is_damage_state", true)
	await get_tree().create_timer(0.2).timeout
	shader_material.set_shader_parameter(&"is_damage_state", false)
	
	if health <= 0:
		queue_free()


func _on_timer_timeout() -> void:
	match state:
		State.IDLE:
			set_state(State.WALK)
		State.WALK:
			set_state(State.IDLE)
		State.ATTACK:
			assert(false, "timer should not run out while in attack state")


func _on_animated_sprite_2d_animation_finished() -> void:
	if state == State.ATTACK:
		set_state(State.IDLE)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is NewPlayer:
		body.receive_attack(ATTACK_DAMAGE)


func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == &"attack":
		var frame := sprite.frame
		if frame == 4:
			hitbox.monitoring = true
		elif frame == 7:
			hitbox.monitoring = false
