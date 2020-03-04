extends Node2D

# 0:Spring 1:Knife 2:Fire 3:Wood 4:Earth

func _ready():
	# $Enemies/Monster.add_collision_exception_with($Enemies/Monster2)
	global.current_scene = get_tree().get_current_scene()
	var enemies = get_node("Enemies").get_children()
	for e in enemies:
		e.get_node("Sprite").set_texture(global.Knife_enemy)
		e.element = 1