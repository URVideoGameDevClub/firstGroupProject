class_name Player
extends CharacterBody2D

const DAMAGE_FLASH_TIME := 0.2
const ATTACK_AREA_X := 16.0
const ATTACK_DAMAGE := 1

@export var attack_enabled := false
@export var glide_enabled := false
@export var jump_count := 1
@export_range(0, 3) var health := 3:
	set(value):
		if value != health:
			Global.player_health_updated.emit(value)
			if value <= 0:
				transition(death_state)
			health = value

var ground_state := GroundPlayerState.new(self)
var air_state := AirPlayerState.new(self)
var death_state := DeathPlayerState.new(self)
var _state: PlayerState

var facing_right := false:
	set(value):
		attack_area.position.x = ATTACK_AREA_X * (1.0 if value else -1.0)
		sprite.flip_h = value
		facing_right = value

var is_attacking := false
# currently only applies to ground player state
var input_frozen := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get(&"parameters/playback")
@onready var sprite: Sprite2D = $Sprite2D
@onready var shader_material: ShaderMaterial = sprite.material
@onready var attack_area: Area2D = $AttackArea
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	Global.item_picked_up.connect(_on_item_picked_up)
	transition(ground_state)
	facing_right = sprite.flip_h


func _physics_process(delta: float) -> void:
	if _state:
		_state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"kill_player"):
		transition(death_state)
	elif attack_enabled and event.is_action_pressed(&"attack"):
		send_attack()


func get_state() -> PlayerState:
	return _state


func transition(target: PlayerState, args: Dictionary[String, Variant] = {}) -> void:
	if _state:
		_state.exit()
	_state = target
	_state.enter(args)


func update_facing() -> void:
	if velocity.x < 0.0:
		facing_right = false
	elif velocity.x > 0.0:
		facing_right = true


func receive_attack(damage: int, knockback_direction := Vector2.ZERO) -> void:
	health -= damage
	shader_material.set_shader_parameter(&"is_damage_state", true)
	await get_tree().create_timer(DAMAGE_FLASH_TIME).timeout
	shader_material.set_shader_parameter(&"is_damage_state", false)


func send_attack() -> void:
	for body: Node2D in attack_area.get_overlapping_bodies():
		if body.has_method(&"receive_attack") and body != self:
			body.receive_attack(ATTACK_DAMAGE)


func _on_item_picked_up(item_name: String) -> void:
	if item_name == "glider":
		glide_enabled = true
