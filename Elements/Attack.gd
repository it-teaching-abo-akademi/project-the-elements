extends Object

class_name Attack

var name:String = 'unknown'
var damage:float = 0.0
var range_effect:float = 0.0
var time_before:float = 0.0
var time_attack:float = 1.0
var time_after:float = 0.0

# The effect the attack can have (e.g Lift/Knock)
# Should be loaded from somewhere
var effect:int = 0

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
