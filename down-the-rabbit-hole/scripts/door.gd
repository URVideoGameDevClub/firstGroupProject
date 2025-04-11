class_name Door
extends Area2D


@export var _target_level := Main.ELevel.NONE
@export var _id := -1
@export var _target_id := -1
@export var _spawn_marker: Marker2D


func _enter_tree() -> void:
    body_entered.connect(_on_body_entered)


func get_spawn_point() -> Vector2:
    return _spawn_marker.global_position


func get_id() -> int:
    return _id


func _on_body_entered(body: Node2D) -> void:
    assert(body is Player, "non player body entered door. check collision layers?")
    
    Global.door_entered.emit(_target_level, _target_id)