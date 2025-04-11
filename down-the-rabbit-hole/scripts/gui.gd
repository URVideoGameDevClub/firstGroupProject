class_name Gui
extends CanvasLayer

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _black_rect: ColorRect = $BlackRect


func get_animation_player() -> AnimationPlayer:
    return _animation_player
