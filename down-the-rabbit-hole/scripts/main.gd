class_name Main
extends Node

enum ELevel {NONE, TEST, A, B, C, D, E}

const LEVEL_SCENES: Dictionary[ELevel, String] = {
	ELevel.NONE: "",
	ELevel.TEST: "uid://c1kslsssaqaov",
	ELevel.A: "",
	ELevel.B: "",
	ELevel.C: "",
	ELevel.D: "",
	ELevel.E: "",
}

@export var has_knife := false
@export var has_glider := false
@export var _player: Player
@export var _gui: Gui
@export var _level: Level
@export var _camera: Camera2D

@onready var _respawn_point := _player.global_position


func _enter_tree() -> void:
	Global.main = self
	Global.door_entered.connect(_on_door_entered)
	Global.checkpoint_entered.connect(func(spawn_point: Vector2) -> void: _respawn_point = spawn_point)


func _process(_delta: float) -> void:
	_camera.global_position = _player.global_position


func _on_door_entered(target_level: ELevel, target_id: int) -> void:
	get_tree().paused = true
	
	var anim := _gui.get_animation_player()
	anim.play(&"fade_to_black")
	await anim.animation_finished
	
	_level.queue_free()
	_level = load(LEVEL_SCENES[target_level]).instantiate()
	add_child(_level)
	
	var doors := _level.get_doors()
	for door: Door in doors:
		door.monitoring = false
	var target_door_index := doors.find_custom(func(door: Door) -> bool:
		return door.get_id() == target_id
	)
	var target_door := doors[target_door_index]
	_respawn_point = target_door.get_spawn_point()

	get_tree().paused = false
	_player.global_position = target_door.get_spawn_point()
	_camera.global_position = _player.global_position
	await get_tree().process_frame
	_camera.reset_smoothing()

	anim.play_backwards(&"fade_to_black")
	await anim.animation_finished
	for door: Door in doors:
		door.monitoring = true
	
