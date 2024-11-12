class_name PauseMenu
extends Control


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		show()
		get_tree().paused = true


func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
