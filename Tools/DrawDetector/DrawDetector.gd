extends Node2D

# An array containing the gestures
# One gesture is made from at least two points
# One gesture also have a time limit
var gestures = Array()

# We can only draw one gesture at a time, but multiple gestures
# can start at the same point
var gestures_in_progress = Array()

# Names of the attacks already done to check for combo
var attacks = []

func _draw():
	# For debug purposes
	for gesture in gestures:
		for point in gesture.points:
			draw_circle(point, gesture.radius, Color.red)
	

func add_gesture(gesture: Gesture):
	gestures.append(gesture)

func _distance_line_point(line_p1: Vector2, line_p2: Vector2, point: Vector2):
	var y2y1 = line_p2.y - line_p1.y
	var x2x1 = line_p2.x - line_p1.x
	var a = abs(y2y1 * point.x - x2x1 * point.y + line_p2.x * line_p1.y - line_p2.y * line_p1.x)
	var sr = sqrt(y2y1 * y2y1 + x2x1 * x2x1)
	
	return a / sr

func _input(event):
	if event.is_action("left_click") and event.is_pressed():
		var pos = get_local_mouse_position()
		print("left! " + str(pos))
		# Check if we are starting a new gesture
		for gesture in gestures:
			if gesture.is_index_valid(pos, 0):
				get_owner().start_gesture()
				# Start drawing this gesture
				gesture.state = 0
				gestures_in_progress.append(gesture)
	
	# Process gestures
	if event is InputEventMouseMotion:
		
		for gesture in gestures_in_progress:
			print("update gesture")
			var temporary_position = get_local_mouse_position()
			if gesture.is_index_valid(temporary_position, gesture.state + 1):
				# It's finished
				gesture.state += 1  # That should complete the gesture
			
			if gesture.is_complete():
				# TODO: complete gesture
				break
			
			var start_point = gesture.points[gesture.state]
			var destination_point = gesture.points[gesture.state + 1]
			
			
			if _distance_line_point(start_point, destination_point, temporary_position) > gesture.radius:
				# The mouse doesn't follow the correct path
				# We need to remove this from the list
				gesture.state = -2
				break
		
		for gesture in gestures:
			if gesture.is_complete():
				gestures_in_progress.erase(gesture)
				print("Gesture complete!: " + str(gesture.points.size()))
				attacks.append(gesture.attack.name)
				# We can check for combo here
				get_owner().attack(gesture.attack)
				gesture.init_again()
				
			elif gesture.state == -2:
				# The gesture was not draw
				gestures_in_progress.erase(gesture)
				get_owner().fail_gesture()
				gesture.init_again()