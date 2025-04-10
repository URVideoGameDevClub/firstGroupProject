class_name AttackPlayerState
extends PlayerState


func _init(p_player: Player) -> void:
	super (p_player)
	player.ready.connect(_on_player_ready)


func enter(_args: Dictionary[String, Variant] = {}) -> void:
	player.animation_state.travel(&"attack")


func physics_update(delta: float) -> void:
	if Global.input_vector():
		player.transition(player.ground_state)


func _on_player_ready() -> void:
	player.animation_tree.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"attack":
		player.transition(player.ground_state)
