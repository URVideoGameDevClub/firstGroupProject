class_name Player
extends CharacterBody2D


var ground_state := GroundPlayerState.new(self)
var air_state := AirPlayerState.new(self)
var state: PlayerState = ground_state

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	transition(ground_state)


func transition(target: PlayerState, args := {}) -> void:
	state.exit()
	state = target
	state.enter(args)
