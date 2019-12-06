extends Object

class_name Action

var element:int = -1 setget set_element, get_element
var direction:int = 1 setget set_direction, get_direction

var parameters = {}

# TODO: element consumed

# It can be an idea to have an 'Effect' class, who handle the effect
# For example, the enemy call methods from this class to create the effect
# without having to check every case itself
# Same for combo effects

# The effect the attack can have (e.g Lift/Knock)
# Should be loaded from somewhere
var effect:int = 0

var is_combo:bool = false setget set_is_combo, is_combo
var combo_effect:int = 0 setget set_combo_effect, get_combo_effect

var points = []

func init_again():
	# TODO: init again everything
	pass

func set_is_combo(ic:bool):
	is_combo = ic

func is_combo():
	return is_combo

func set_combo_effect(cb:int):
	combo_effect = cb

func get_combo_effect():
	return combo_effect

func set_element(e:int):
	element = e

func get_element():
	return element

func set_direction(dir:int):
	direction = dir

func get_direction():
	return direction

func set_parameter(name, data):
	parameters[name] = data

func get_parameter(name):
	if parameters.has(name):
		return parameters[name]
	else:
		return null
