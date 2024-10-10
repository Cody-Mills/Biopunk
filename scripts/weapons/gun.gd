class_name Item
extends Node

@export var CLIP_SIZE := 8
@export var MAX_AMMO := 32
var current_ammo : int

func _ready() -> void:
	current_ammo = CLIP_SIZE

func _fire() -> void:
	print("fire")
	#Get parent node "fire position" 
	#fire a bullet
	#play bullet firing effect
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _reload() -> void:
	print("reload")
	pass
	#if 'ui_reload' pressed or currentAmmo == 0
	#play reload animation
	#replensih bullets
	
