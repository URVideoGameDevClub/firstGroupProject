extends Node2D


@onready var sprite = $AnimatedSprite2D
@onready var player = $AnimationPlayer
@onready var tree = $AnimationTree
@onready var state = tree.get("parameters/playback")
