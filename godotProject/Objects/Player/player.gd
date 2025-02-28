class_name Player
extends CharacterBody2D

const DAMAGE_FLASH_TIME := 0.2


var ground_state := GroundPlayerState.new(self)
var air_state := AirPlayerState.new(self)
var death_state := DeathPlayerState.new(self)
var state: PlayerState

var facing_right := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get(&"parameters/playback")
@onready var sprite: Sprite2D = $Sprite2D
@onready var shader_material: ShaderMaterial = sprite.material


func _ready() -> void:
	transition(ground_state)


func _physics_process(delta: float) -> void:
	if state:
		state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"kill_player"):
		transition(death_state)


func transition(target: PlayerState) -> void:
	if state:
		state.exit()
	state = target
	state.enter()


func update_facing() -> void:
	if velocity.x < 0.0:
		facing_right = false
		sprite.flip_h = false
	elif velocity.x > 0.0:
		facing_right = true
		sprite.flip_h = true


func receive_attack(damage: int) -> void:
	shader_material.set_shader_parameter(&"is_damage_state", true)
	await get_tree().create_timer(DAMAGE_FLASH_TIME).timeout
	shader_material.set_shader_parameter(&"is_damage_state", false)
