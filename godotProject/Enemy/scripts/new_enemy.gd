class_name Enemy
extends CharacterBody2D

@export var health: int
# Method that changes the enemy's state 
func takeDamage(damage: int):
	print("I was attacked")
