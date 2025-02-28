class_name Gui
extends CanvasLayer

signal fade_to_black_finished

@onready var anim: AnimationPlayer = $AnimationPlayer


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"fade_to_black":
		fade_to_black_finished.emit()
