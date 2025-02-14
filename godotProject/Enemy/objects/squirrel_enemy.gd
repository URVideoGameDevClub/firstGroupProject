class_name SquirrelEnemy
extends Enemy

enum State { IDLE, WALK, ATTACK }

const IDLE_TIME_MIN := 2.0
const IDLE_TIME_MAX := 3.0
const WALK_TIME_MIN := 3.0
const WALK_TIME_MAX := 5.0
const WALK_SPEED := 100.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var ground_cast_l: RayCast2D = $GroundCastL
@onready var ground_cast_r: RayCast2D = $GroundCastR

@onready var facing_right := sprite.flip_h:
	set(value):
		facing_right = value
		# TODO: flip sprite

var state: State:
	set(value):
		match value:
			State.IDLE:
				sprite.play(&"idle")
				timer.start(randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX))
			State.WALK:
				sprite.play(&"walk")
				timer.start(randf_range(WALK_TIME_MIN, WALK_TIME_MAX))
				facing_right = randi() % 2 == 0
			State.ATTACK:
				sprite.play(&"attack")
		state = value


func _ready() -> void:
	# Call Setters
	state = State.IDLE


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			pass
		State.WALK:
			if facing_right and not ground_cast_r.is_colliding():
				self.facing_right = false
			elif not facing_right and not ground_cast_l.is_colliding():
				self.facing_right = true
			velocity.x = WALK_SPEED * int(facing_right)
			move_and_slide()
		State.ATTACK:
			pass


func _on_timer_timeout() -> void:
	match state:
		State.IDLE:
			state = State.WALK
		State.WALK:
			state = State.IDLE
		State.ATTACK:
			push_error("Why is timer running out when attack state ?!?")
			state = State.IDLE


func _on_animated_sprite_2d_animation_finished() -> void:
	if state == State.ATTACK:
		state = State.IDLE
