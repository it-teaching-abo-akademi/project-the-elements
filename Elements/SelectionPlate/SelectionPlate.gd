extends Node2D

const elements = ["Spring", "Knife", "Fire", "Wood", "Earth"]

func _ready():
	pass 


func lighten_element(selected_element : String):
	for element in elements:
		if element != selected_element:
			get_node(element).play("Idle")
		else:
			get_node(element).play("Shine")