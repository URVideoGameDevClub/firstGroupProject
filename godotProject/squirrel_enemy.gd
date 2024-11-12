class_name SquirrelEnemy
extends BaseEnemy


@export var move_speed := 0.0
@export var acceleration := 0.0
@export var gravity := 0.0


@onready var anim_sprite := get_node("AnimatedSprite2D")


func _ready() -> void:
	for i in 10:
		anim_sprite.play("idle")
		await get_tree().create_timer(2.0).timeout
		anim_sprite.play("walk")
		await get_tree().create_timer(2.0).timeout
		anim_sprite.play("attack")
		await get_tree().create_timer(2.0).timeout
