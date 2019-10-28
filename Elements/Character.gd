extends KinematicBody2D

const UP = global.UP
const GRAVITY = global.GRAVITY
const SPEED = global.CHARACTER_SPEED
const JUMP_HEIGHT = global.JUMP_HEIGHT
const FLYING_SPEED = global.FLYING_SPEED
const FLYING_ADJUST_SPEED = global.FLYING_ADJUST_SPEED
const BURST_SPEED = global.BURST_SPEED
const FUEL_CONSUME = global.FUEL_CONSUME
const BURST_FUEL_CONSUME = global.BURST_FUEL_CONSUME
const ELEMENTS = global.ELEMENTS
const friction = global.FRICTION

export(float) var ATTACK_RANGE = 50.0
export(float) var MINIMUM_LINE_LENGTH = 50.0

var fuel : int = 2000
var burst = true
var state = global.CHARACTER_STATES['STATE_IDLE']
var motion = Vector2()
var element_left = 0 #index of element
var element_right = 1 #index of element

#element selection
onready var selection_plate = $SelectionPlate


#temp var
var element_look = 0

class_name Character

signal start_gesture

# Parameter: Attack, element
signal character_attack

# List of attack names, to check if there is a combo
var combo_list = []

func _draw():
	draw_circle(to_local(position), ATTACK_RANGE, Color(1.0, 0.0, 0.0, 0.5))

func _physics_process(delta):
	motion.y += GRAVITY * delta
	#$Sprite.play(ELEMENTS[element_look])
	motion.x = lerp(motion.x, 0, friction)
	
	if state == global.CHARACTER_STATES['STATE_FLY']:
		if(burst):
			# print("burst")
			burst = false
			motion += -get_local_mouse_position().normalized() * BURST_SPEED * delta
			fuel -= BURST_FUEL_CONSUME
		else:
			motion += -get_local_mouse_position().normalized() * FLYING_SPEED * delta
			fuel -= FUEL_CONSUME
		# print(fuel)
		
	if(!is_on_floor() || state == global.CHARACTER_STATES['STATE_FLY']):
		if Input.is_action_pressed("move_right"):
			motion.x += FLYING_ADJUST_SPEED * delta
		elif Input.is_action_pressed("move_left"):
			motion.x += -FLYING_ADJUST_SPEED * delta
		#$Sprite.play("Jump")
	else: #if there is no flying effect
		if (abs(motion.x) > SPEED):
			motion *= 0.95
		else:
			if Input.is_action_pressed("move_right"):
				motion.x = SPEED * delta
			elif Input.is_action_pressed("move_left"):
				motion.x = -SPEED * delta 
			else:
				motion.x = 0
				#$Sprite.play("Idle")
	motion = move_and_slide(motion,UP, false, 4, PI/4, true)
	

var attack_begin
var last_mouse_position
var attack_end
var coordinate_array = Array()
var frame_count : int = 0

func _input(event):
	#show selection plate
	if Input.is_action_pressed("ctrl"):
		selection_plate.show()
		selection_plate.lighten_element(get_element_by_angle(get_mouse_angle()))
		
	if Input.is_action_just_released("ctrl"):
		selection_plate.hide()
		$Sprite.play(get_element_by_angle(get_mouse_angle()))
	
	#change elements
	if Input.is_action_just_pressed("change_element_left_previous"):
		element_left = change_element_to_previous(element_left, element_right)
	if Input.is_action_just_pressed("change_element_left_next"):
		element_left = change_element_to_next(element_left, element_right)
	if Input.is_action_just_pressed("change_element_right_previous"):
		element_right = change_element_to_previous(element_right, element_left)
	if Input.is_action_just_pressed("change_element_right_next"):
		element_right = change_element_to_next(element_right, element_left)
	
	#flip sprite
	if Input.is_action_pressed("move_right"):
				$Sprite.flip_h = false
	elif Input.is_action_pressed("move_left"):
				$Sprite.flip_h = true
				
	#temp
	if Input.is_action_just_pressed("space"):
		element_look = change_element_to_next(element_look, 6)
	
	if state == global.CHARACTER_STATES['STATE_IDLE']:
		if Input.is_action_pressed("left_mouse_click"):
			if ELEMENTS[element_left] == 'Spring':
				state = global.CHARACTER_STATES['STATE_FLY']
				burst = true
			else:
				state = global.CHARACTER_STATES['STATE_ATTACK']
				print(ELEMENTS[element_left])
				attack_begin = get_global_mouse_position()
				#last_mouse_position = attack_begin
				#print(attack_begin)
				coordinate_array.append(attack_begin)
				state = global.CHARACTER_STATES['STATE_IDLE']
		if Input.is_action_pressed("right_mouse_click"):
			if ELEMENTS[element_right] == 'Spring':
				state = global.CHARACTER_STATES['STATE_FLY']
				burst = true
			else:
				state = global.CHARACTER_STATES['STATE_ATTACK']
				print(ELEMENTS[element_right])
				attack_begin = get_global_mouse_position()
				#last_mouse_position = attack_begin
				#print(attack_begin)
				coordinate_array.append(attack_begin)
				state = global.CHARACTER_STATES['STATE_IDLE']
	elif state == global.CHARACTER_STATES['STATE_ATTACK']:
		#attacking mode detection here
		
		#
		if event is InputEventMouseMotion:
			frame_count+=1
			if(frame_count == 5):
				frame_count = 0
				coordinate_array.append(get_global_mouse_position())
			#print("Attacking mode:", event.position)
			#last_mouse_position = get_global_mouse_position()
			#some manipulation here
		if Input.is_action_pressed("left_mouse_click"):
			state = global.CHARACTER_STATES['STATE_IDLE']
			attack_end = get_global_mouse_position()
			coordinate_array.append(attack_end)
			# attack(coordinate_array)
			coordinate_array.clear()
	if state == global.CHARACTER_STATES['STATE_FLY'] and Input.is_action_just_released("left_mouse_click"):
		#flying logic in the _physics_process function
		state = global.CHARACTER_STATES['STATE_IDLE']


func _check_combo(attack:Attack):
	"""
	Check if there is a combo, and if there is,
	update the Attack object and return it
	"""
	
	combo_list.append(attack.name)
	
	# If there is a combo, we don't try to check others
	if combo_list.size() >= 3:
		# Check size 3 combo
		var three = combo_list[combo_list.size() - 1]
		var two = combo_list[combo_list.size() - 2]
		var one = combo_list[combo_list.size() - 3]
		
		if one == "Thrust" and two == "Thrust" and three == "Thrust":
			# Lunge
			attack.combo_effect = 1
			return attack
		elif one == "Thrust" and two == "Thrust" and three == "Slash":
			# Sword wave (sword intent)
			attack.combo_effect = 2
			return attack
	if combo_list.size() >= 2:
		var two = combo_list[combo_list.size() - 1]
		var one = combo_list[combo_list.size() - 2]
		
		# Check size 2 combo
		if one == "Lift" and two == "Arrow":
			# Arrow power up: +speed +damage
			attack.combo_effect = 3
			return attack
		elif (one == "Lift" and two == "Slash") or (one == "Thrust" and two == "Slash"):
			# Heavy slash
			attack.combo_effect = 4
			return attack
		elif one == "Lift" and two == "Lift":
			# Special lift
			attack.combo_effect = 5
			return attack
		elif one == "Thrust" and two == "Lift":
			# Fast lift
			attack.combo_effect = 6
			return attack
		elif one == "Slash" and two == "Thrust":
			# Laijutsu
			attack.combo_effect = 7
			return attack
		elif one == "Slash" and two == "Lift":
			# Higher lift
			attack.combo_effect = 8
			return attack
	
	return attack
	
func attack(attack:Attack):
	print("Attack " + attack.name)
	
	attack = _check_combo(attack)
	
	emit_signal("character_attack", attack)
	
	var animator = null
	if attack.name == "Slash":
		animator = $SwordAnimations
	elif attack.name == "Thrust":
		animator = $SpearAnimations
	
	if animator:
		animator.play("Appear")
		animator.queue("Attack")
		animator.queue("Disappear")
	

func start_gesture(button):
	if button == 1:
		print("start left gesture")
	else:
		print("start right gesture")
	emit_signal("start_gesture", button)

func _point_is_in_range(point:Vector2):
	return point.x > position.x - ATTACK_RANGE and point.x < position.x + ATTACK_RANGE \
	and point.y > position.y - ATTACK_RANGE and point.y < position.y + ATTACK_RANGE

func complete_gesture(gesture, button):
	if button == 1:
		print("complete left gesture")
	else:
		print("complete right gesture")
	
	if gesture.line:
		print("It's a line")
		if gesture.direction == global.DIRECTION['DIR_N']:
			print("Direction: N")
		elif gesture.direction == global.DIRECTION['DIR_S']:
			print("Direction: S")
		elif gesture.direction == global.DIRECTION['DIR_E']:
			print("Direction: E")
		elif gesture.direction == global.DIRECTION['DIR_W']:
			print("Direction: W")
		elif gesture.direction == global.DIRECTION['DIR_NE']:
			print("Direction: NE")
		elif gesture.direction == global.DIRECTION['DIR_NW']:
			print("Direction: NW")
		elif gesture.direction == global.DIRECTION['DIR_SE']:
			print("Direction: SE")
		elif gesture.direction == global.DIRECTION['DIR_SW']:
			print("Direction: SW")

	var attack = Attack.new()
	if button == 1:
		attack.element = element_left
	else:
		attack.element = element_right

	if gesture.points[0].distance_squared_to(gesture.points.back()) < MINIMUM_LINE_LENGTH * MINIMUM_LINE_LENGTH:
		return

	if ELEMENTS[attack.element] == "Knife":
		if gesture.direction == global.DIRECTION['DIR_SE']:
			attack.name = "Slash"
			attack.damage = 42.0
			attack.start_position = position
			attack.range_effect = 100.0
		elif gesture.direction == global.DIRECTION['DIR_E']:
			attack.name = "Thrust"
			attack.damage = 18.0
			attack.start_position = position
			attack.range_effect = 200.0
		elif gesture.direction == global.DIRECTION['DIR_NE']:
			attack.name = "Lift"
			attack.damage = 5.0
			attack.start_position = position
	elif ELEMENTS[attack.element] == "Fire":
		# Fireball
		# Arrow
		# if the line is in direction of the player, it's an arrow. Else it's a fireball
		if position.distance_squared_to(gesture.points[0]) > position.distance_squared_to(gesture.points[1]):
			# Direction of the player
			attack.name = "Arrow"
			attack.damage = 10.0
			attack.start_position = position
		else:
			attack.name = "Fireball"
			attack.damage = 15.0
			attack.start_position = position
		
		# Rain of arrows (maybe later)
	elif ELEMENTS[attack.element] == "Spring":
		# Nothing, we fly
		pass
	elif ELEMENTS[attack.element] == "Wood":
		# Attack anywhere, not really designed yet
		pass
	elif ELEMENTS[attack.element] == "Earth":
		# Create a shield
		pass
	
	if attack.name != "unknown":
		attack(attack)
	

func change_element_to_next(element:int, element_chosen:int):
	"""
	change the element to the next unseleted element
	"""
	element += 1
	if element < ELEMENTS.size():
		if element != element_chosen:
			return element
		else:
			return change_element_to_next(element, element_chosen)
	else:
		return change_element_to_next(-1, element_chosen)
		
func change_element_to_previous(element:int, element_chosen:int):
	"""
	change the element to the previous unseleted element
	"""
	element -= 1
	if element >= 0:
		if element != element_chosen:
			return element
		else:
			return change_element_to_previous(element, element_chosen)
	else:
		return change_element_to_previous(ELEMENTS.size(), element_chosen)

func get_mouse_angle():
	"""
	get the angle between mouse and + x axis in degrees
	"""
	return get_angle_to(get_global_mouse_position()) / PI * 180

func get_element_by_angle(angle : float):
	"""
	change the element using the selection plate
	"""
	if angle < 18 and angle >= -54:
		return "Fire"
	elif angle < -54 and angle >= -126:
		return "Earth"
	elif angle < -126 or angle >= 162:
		return "Wood"
	elif angle < 162 and angle >= 90:
		return "Spring"
	elif angle < 90 and angle >= 18:
		return "Knife"
	

func _ready():
	selection_plate.hide()
	# Create gestures
	# Eventually it should be loaded from a file
	# var attack = Attack.new()
	# attack.damage = 42.0
	# attack.name = 'Random name'
	
	# var gesture = Gesture.new(1.0, [Vector2(-100,-100), Vector2(100,100)])
	# gesture.radius = 25.0
	# gesture.attack = attack
	
	# $DrawDetector.add_gesture(gesture)
	pass
