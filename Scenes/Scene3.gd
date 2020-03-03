extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# $Enemies/Monster.add_collision_exception_with($Enemies/Monster2)
	global.current_scene = get_tree().get_current_scene()
	var enemies = get_node("Enemies").get_children()
	for e in enemies:
		e.get_node("Sprite").set_texture(global.Spring_enemy)
