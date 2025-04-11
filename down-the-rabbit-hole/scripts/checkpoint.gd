extends Area2D


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    assert(body is Player)

    Global.checkpoint_entered.emit(global_position)
