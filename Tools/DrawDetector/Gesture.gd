extends Object
# Class Gesture
# Represents a gesture with points and a time limit to draw it

class_name Gesture

var points = Array() setget set_points, get_points
var line:bool = false setget set_is_line, is_line

var computed:bool = false

var direction = -1 setget set_direction, get_direction

var MAX_DISTANCE:float = 5.0


func set_points(pts:Array):
	if not points.empty():
		points.clear()
	for p in pts:
		points.append(p)

func get_points():
	return points

func set_is_line(is_line:bool):
	line = is_line

func is_line():
	"""
	To know if it's a line, we get the first and last point and compute the angle of the line formed
	Then we can check if every point is not far from the line
	"""
	computed = true
	if points.size() < 2:
		direction = -1
		return false
	var first = points[0]
	var last = points.back()
	
	for i in range(1, points.size()):
		if _distance_line_point(first, last, points[i]) > MAX_DISTANCE:
			direction = -1
			return false
	
	# It is considered as a line
	# We now need to know the direction of the line
	
	# Compute the angle between the line and the x axe
	var angle_with_x = first.angle_to_point(last)
	while angle_with_x > 2 * PI:
		angle_with_x -= 2 * PI
	
	if angle_with_x < 0:
		angle_with_x += 2 * PI
	
	if angle_with_x < PI / 8:
		direction = global.DIRECTION['DIR_W']
	elif angle_with_x < 3 * PI / 8:
		direction = global.DIRECTION['DIR_NW']
	elif angle_with_x < 5 * PI / 8:
		direction = global.DIRECTION['DIR_N']
	elif angle_with_x < 7 * PI / 8:
		direction = global.DIRECTION['DIR_NE']
	elif angle_with_x < 9 * PI / 8:
		direction = global.DIRECTION['DIR_E']
	elif angle_with_x < 11 * PI / 8:
		direction = global.DIRECTION['DIR_SE']
	elif angle_with_x < 13 * PI / 8:
		direction = global.DIRECTION['DIR_S']
	elif angle_with_x < 15 * PI / 8:
		direction = global.DIRECTION['DIR_SW']
	else:
		direction = global.DIRECTION['DIR_W']

	return true

func set_direction(dir):
	direction = dir

func get_direction():
	if not computed:
		is_line()
	return direction

func _distance_line_point(line_p1: Vector2, line_p2: Vector2, point: Vector2):
	var y2y1 = line_p2.y - line_p1.y
	var x2x1 = line_p2.x - line_p1.x
	var a = abs(y2y1 * point.x - x2x1 * point.y + line_p2.x * line_p1.y - line_p2.y * line_p1.x)
	var sr = sqrt(y2y1 * y2y1 + x2x1 * x2x1)
	
	if sr == 0:
		return 0
	
	return a / sr
