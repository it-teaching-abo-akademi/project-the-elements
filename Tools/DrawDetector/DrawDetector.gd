extends Node2D

var points = Array()
var started:bool = false
var button:int = -1 # 0 right, 1 left

export(float) var SQUARRED_DISTANCE = 8.0

func _draw():
	var prev = null
	for point in points:
		if prev != null:
			draw_line(prev, to_local(point), Color(0.0, 0.0, 0.75), 2.0)
		prev = to_local(point)
		# draw_circle(point, 1, Color.red)


func _input(event):
	if event.is_action_pressed("left_mouse_click") and not started:
		# Begin to draw
		button = 1
		points.append(get_global_mouse_position())
		get_owner().start_gesture(button)
		started = true
	elif event.is_action_pressed("right_mouse_click") and not started:
		# Begin to draw
		button = 0
		points.append(get_global_mouse_position())
		get_owner().start_gesture(button)
		started = true

	if (button == 1 and event.is_action_released("left_mouse_click")) \
	or (button == 0 and event.is_action_released("right_mouse_click")):
		# End drawing
		points.append(get_global_mouse_position())
		# Create gesture to send to the Character (the parent)
		var gesture = Gesture.new()
		gesture.points = points
		get_owner().complete_gesture(gesture, button)
		button = -1
		points.clear()
		update()
		started = false

	if started and event is InputEventMouseMotion:
		var current_position = get_global_mouse_position()
		if not points.empty():
			if current_position.distance_squared_to(points.back()) > SQUARRED_DISTANCE:
				points.append(current_position)
				update()
