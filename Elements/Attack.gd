extends Object

class_name Attack

var name:String = 'unknown'
var damage:float = 0.0
var range_effect:float = 0.0
var time_before:float = 0.0
var time_attack:float = 1.0
var time_after:float = 0.0

# It can be an idea to have an 'Effect' class, who handle the effect
# For example, the enemy call methods from this class to create the effect
# without having to check every case itself
# Same for combo effects

# The effect the attack can have (e.g Lift/Knock)
# Should be loaded from somewhere
var effect:int = 0

var is_combo:bool = false setget set_is_combo, is_combo
var combo_effect:int = 0 setget set_combo_effect, get_combo_effect

# It's an aboslute position, not relative to the character
var start_position:Vector2 = Vector2(0.0, 0.0) setget set_start_position, get_start_position

func set_start_position(position: Vector2):
	start_position.x = position.x
	start_position.y = position.y

func get_start_position():
	return Vector2(start_position.x, start_position.y)

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
