class_name SquirrelEnemy
extends Enemy


enum State { IDLE, WALK, ATTACK }


const IDLE_TIME_MIN := 2.0
const IDLE_TIME_MAX := 3.0
const WALK_TIME_MIN := 3.0
const WALK_TIME_MAX := 5.0


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var ground_cast_l: RayCast2D = $GroundCastL
@onready var ground_cast_r: RayCast2D = $GroundCastR


var facing_right: bool
var state: State:
	set(value):
		match value:
			State.IDLE:
				sprite.play(&"idle")
				timer.start(randf_range(IDLE_TIME_MIN, IDLE_TIME_MAX))
			State.WALK:
				sprite.play(&"walk")
				timer.start(randf_range(WALK_TIME_MIN, WALK_TIME_MAX))
			State.ATTACK:
				sprite.play(&"attack")
		state = value


func _ready() -> void:
	state = State.IDLE
	facing_right = sprite.flip_h


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			pass
		State.WALK:
			pass
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
