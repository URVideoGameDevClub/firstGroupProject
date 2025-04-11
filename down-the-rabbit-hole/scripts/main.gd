class_name Main
extends Node

@export var has_knife := false
@export var has_glider := false
@export var player: Player


func _enter_tree() -> void:
    Global.main = self
