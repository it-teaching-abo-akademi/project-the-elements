extends Control

const _ELEMENT_COLORS = [
	Color(0, 0.5, 1, 1), # Spring
	Color(0.96, 0.96, 0.96, 1), # Knife
	Color(0.86, 0.08, 0.24, 1 ), # Fire
	Color(0.2, 0.8, 0.2, 1), # Wood
	Color(0.82, 0.41, 0.12, 1 ), # Earth
]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Health_on_hp_changed(v):
	get_node("hp_amount").change_value(v)


func _on_Health_set_max_hp(v):
	get_node("hp_amount").set_max_value(v)


func _on_Player_update_element_indicators(element_left, element_right): #index of element   0:Spring 1:Knife 2:Fire 3:Wood 4:Earth
	get_node("mouse_indicator/left").modulate = _ELEMENT_COLORS[element_left]
	get_node("mouse_indicator/right").modulate = _ELEMENT_COLORS[element_right]
	if((element_left == 0)||(element_right) == 0):
		get_node("spring_amount/curent_element").visible = true
	else:
		get_node("spring_amount/curent_element").visible = false
	if((element_left == 1)||(element_right) == 1):
		get_node("knife_amount/curent_element").visible = true
	else:
		get_node("knife_amount/curent_element").visible = false
	if((element_left == 2)||(element_right) == 2):
		get_node("fire_amount/curent_element").visible = true
	else:
		get_node("fire_amount/curent_element").visible = false
	if((element_left == 3)||(element_right) == 3):
		get_node("wood_amount/curent_element").visible = true
	else:
		get_node("wood_amount/curent_element").visible = false
	if((element_left == 4)||(element_right) == 4):
		get_node("earth_amount/curent_element").visible = true
	else:
		get_node("earth_amount/curent_element").visible = false


func _on_Elements_set_max_value(type, value):
	match type:
		0:
			get_node("spring_amount").set_max_value(value)
		1:
			get_node("knife_amount").set_max_value(value)
		2:
			get_node("fire_amount").set_max_value(value)
		3:
			get_node("wood_amount").set_max_value(value)
		4:
			get_node("earth_amount").set_max_value(value)


func _on_Elements_change_value(type, value):
	match type:
		0:
			get_node("spring_amount").change_value(value)
		1:
			get_node("knife_amount").change_value(value)
		2:
			get_node("fire_amount").change_value(value)
		3:
			get_node("wood_amount").change_value(value)
		4:
			get_node("earth_amount").change_value(value)


func _on_Elements_change_max_value(type, value):
	match type:
		0:
			get_node("spring_amount").change_max_value(value)
		1:
			get_node("knife_amount").change_max_value(value)
		2:
			get_node("fire_amount").change_max_value(value)
		3:
			get_node("wood_amount").change_max_value(value)
		4:
			get_node("earth_amount").change_max_value(value)
