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

var fuel : int = 2000
var burst = true
var state = global.CHARACTER_STATES['STATE_IDLE']
var motion = Vector2()
var element_left = 0 #index of element
var element_right = 1 #index of element

#temp var
var element_look = 0

class_name Character

func _physics_process(delta):
	motion.y += GRAVITY
	$Sprite.play(ELEMENTS[element_look])
	
	if state == global.CHARACTER_STATES['STATE_FLY']:
		if(burst):
			print("burst")
			burst = false
			motion += -get_local_mouse_position().normalized() * BURST_SPEED
			fuel -= BURST_FUEL_CONSUME
		else:
			motion += -get_local_mouse_position().normalized() * FLYING_SPEED
			fuel -= FUEL_CONSUME
		print(fuel)
		
	if(!is_on_floor() || state == global.CHARACTER_STATES['STATE_FLY']):
		if Input.is_action_pressed("move_right"):
			motion.x += FLYING_ADJUST_SPEED
		elif Input.is_action_pressed("move_left"):
			motion.x += -FLYING_ADJUST_SPEED
		#$Sprite.play("Jump")
	else: #if there is no flying effect
		if (abs(motion.x) > SPEED):
			motion *= 0.95
		else:
			if Input.is_action_pressed("move_right"):
				motion.x = SPEED
				$Sprite.flip_h = false
				#$Sprite.play("Run")
			elif Input.is_action_pressed("move_left"):
				motion.x = -SPEED
				$Sprite.flip_h = true
				#$Sprite.play("Run")
			else:
				motion.x = 0
				#$Sprite.play("Idle")
	motion = move_and_slide(motion,UP)
	

var attack_begin
var last_mouse_position
var attack_end
var coordinate_array = Array()
var frame_count : int = 0

func _input(event):
	#change elements
	if Input.is_action_just_pressed("change_element_left_previous"):
		element_left = change_element_to_previous(element_left, element_right)
	if Input.is_action_just_pressed("change_element_left_next"):
		element_left = change_element_to_next(element_left, element_right)
	if Input.is_action_just_pressed("change_element_right_previous"):
		element_right = change_element_to_previous(element_right, element_left)
	if Input.is_action_just_pressed("change_element_right_next"):
		element_right = change_element_to_next(element_right, element_left)
	
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
			attack(coordinate_array)
			coordinate_array.clear()
	elif state == global.CHARACTER_STATES['STATE_FLY']:
		#flying logic in the _physics_process function
			state = global.CHARACTER_STATES['STATE_IDLE']

func attack(coordinate_array:Array):
	print(coordinate_array)
	pass

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


func _ready():
	# Create gestures
	# Eventually it should be loaded from a file
	var attack = Attack.new()
	attack.damage = 42.0
	attack.name = 'Random name'
	
	var gesture = Gesture.new(1.0, [Vector2(-100,-100), Vector2(100,100)])
	gesture.radius = 25.0
	gesture.attack = attack
	
	$DrawDetector.add_gesture(gesture)
	
