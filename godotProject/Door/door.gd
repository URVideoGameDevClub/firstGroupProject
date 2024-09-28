extends Area2D

func _ready():
	add_to_group("door")

func _on_body_entered(body: Node2D) -> void:
	if Input.is_action_pressed("jump"):
		print("Happy Birthday!!")
