class_name Player
extends CharacterBody2D


var ground_state := GroundPlayerState.new(self)
var air_state := AirPlayerState.new(self)
var state: PlayerState

var facing_right := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get(&"parameters/playback")
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	transition(ground_state)


func _physics_process(delta: float) -> void:
	if state:
		state.physics_update(delta)


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
