extends Object
# Class Gesture
# Represents a gesture with points and a time limit to draw it

class_name Gesture

var points = Array() setget set_points, get_points
var time_limit:float = 0.0 setget set_time_limit, get_time_limit

# The maximum offset the drawing can have (it means that it can start somewhere else)
# var offset: float = 0.0 setget set_offset, get_offset

# The radius to valid each point
var radius: float = 5.0 setget set_radius, get_radius

# Tell how much index are already been 'draw'. -1 to 'not started'
var state: int = -1 setget set_state, get_state

func _init(time_max: float, pts: Array = Array()):
	time_limit = time_max
	points = pts
	state = -1

func add_point(coords: Vector2):
	points.append(coords)

# Check if the given position is on a point
func is_index_valid(position: Vector2, index: int = 0):
	# TODO: check if index is not outside the array
	var point = points[index]
	
	if position.x <= point.x + radius and position.x >= point.x - radius \
	and position.y <= point.y + radius and position.y >= point.y - radius:
		return true
	return false

func look_valid_index(position: Vector2):
	var index = 0
	for point in points:
		if is_index_valid(position, index):
			return index
		index += 1
	return -1

func is_complete():
	return state >= points.size() - 1

func init_again():
	state = -1

###
# Getters/Setters
###

func set_time_limit(time: float):
	time_limit = time

func get_time_limit():
	return time_limit

func set_points(pts: Array):
	points = pts

func get_points():
	return points

#func set_offset(o: float):
#	offset = o

#func get_offset():
#	return offset

func set_radius(r: float):
	radius = r

func get_radius():
	return radius

func set_state(s: int):
	state = s

func get_state():
	return state