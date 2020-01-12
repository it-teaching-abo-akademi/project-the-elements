extends Object
# Class Gesture
# Represents a gesture with points and a time limit to draw it

class_name Gesture

export(float) var MINIMUM_LINE_LENGTH = 50.0

var points = Array() setget set_points, get_points
var line:bool = false setget set_is_line, is_line

var computed:bool = false

var direction = -1 setget set_direction, get_direction

var MAX_DISTANCE:float = 5.0

var angle_with_x
var first
var last
	
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
	if points.size() < 2 or points[0].distance_squared_to(points.back()) < MINIMUM_LINE_LENGTH * MINIMUM_LINE_LENGTH:
		direction = -1
		return false
	first = points[0]
	last = points.back()
	
	for i in range(1, points.size()):
		if _distance_line_point(first, last, points[i]) > MAX_DISTANCE:
			direction = -1
			return false
	
	# It is considered as a line
	# We now need to know the direction of the line
	
	# Compute the angle between the line and the x axe
	angle_with_x = first.angle_to_point(last)
	while angle_with_x > 2 * PI:
		angle_with_x -= 2 * PI
	
	if angle_with_x < 0:
		angle_with_x += 2 * PI
	
	direction = angle_with_x
	
	print("line")
	return true

func get_angle_with_x():
	if angle_with_x:
		return angle_with_x

func set_direction(dir):
	direction = dir

func get_direction():
	if last != null and first != null:
		return (last-first).normalized()

func _distance_line_point(p1: Vector2, p2: Vector2, p: Vector2):
	var vector = (p-p1) - (p-p1)*(p2-p1)*(p2-p1)/p1.distance_squared_to(p2)
	return 3