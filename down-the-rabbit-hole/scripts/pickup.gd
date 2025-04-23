class_name Pickup
extends Area2D

@export var item_kind := Main.ItemKind.NONE


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    assert(body is Player)

    Global.item_picked_up.emit(item_kind)
