extends Node2D
class_name VFXTrail

export(Vector2) var from = Vector2.ZERO
export(Vector2) var to = Vector2.ZERO

enum Repartition {
	REGULAR,
	RANDOM
}

export(Repartition) var repartition = 0
export(int) var point_count = 10

export(Repartition) var line_width = 0
export(int) var minimum_line_width = 5
export(int) var maximum_line_width = 10

export(Repartition) var line_length = 0
export(int) var minimum_length = 10
export(int) var maximum_length = 15

var nodes = []

func _ready():
	if repartition == Repartition.RANDOM:
		randomize()
	
	# Create the points
	var points = []
	if repartition == Repartition.REGULAR:
		var space_between = 1.0 / point_count
		var pos = 0
		for i in range(point_count):
			var point = (1 - pos) * from + pos * to
			points.append(point)
			pos += space_between
	elif repartition == Repartition.RANDOM:
		for i in range(point_count):
			var r = randf()
			var point = (1 - r) * from + r * to
			points.append(point)
	
	print(str(points))
	var i = 0
	for point in points:
		var node = Node2D.new()
		node.position = point
		var node_name = "VFXNode" + str(i)
		node.set_name(node_name)
		add_child(node)
		nodes.append(node)
	
		var trail = Trail2D.new()
		
		add_child(trail)
		trail.set_target(node)
		
		if line_width == Repartition.RANDOM:
			trail.width = (randi() % (maximum_line_width - minimum_line_width)) + minimum_line_width
		elif line_width == Repartition.REGULAR:
			trail.width = minimum_line_width
		
		if line_length == Repartition.RANDOM:
			trail.trail_length = (randi() % (maximum_length - minimum_length)) + minimum_length
		elif line_length == Repartition.REGULAR:
			trail.trail_length = minimum_length
		i += 1
