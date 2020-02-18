extends KinematicBody2D

class_name Character

#element selection
onready var selection_plate = $SelectionPlate
onready var arrow_scene = preload("res://Elements/Arrow.tscn")
onready var fireball_scene = preload("res://Elements/Fireball.tscn")

const ELEMENTS = ["Spring", "Knife", "Fire", "Wood", "Earth"]

const UP = global.UP
const GRAVITY = global.GRAVITY
const SPEED = 150
const JUMP_HEIGHT = -500  #character jumping height
const FLYING_SPEED = 20  #character flying speed 
const FLYING_ADJUST_SPEED = 5 #character adjusting speed while flying
const BURST_SPEED = 50  #character burst speed
const FUEL_CONSUME = 10  #character fuel consume per time unit
const BURST_FUEL_CONSUME = 20  #character burst fuel consuming per time unit
const friction = global.FRICTION
const MAX_FLYING_SPEED = 800  #character flying speed 

#Elements
var FIRE = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var SPRING = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var WOOD = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var EARTH = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var KNIFE = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}

#properties
var health
var defence
var element_left = 0 #index of element   0:Spring 1:Knife 2:Fire 3:Wood 4:Earth
var element_right = 1 #index of element   0:Spring 1:Knife 2:Fire 3:Wood 4:Earth
var face_direction : int = 1 # 1: look right, -1 left

var motion = Vector2()

var element_handler # Handles collectable elements

var current_jump = null
var jump_timer = 0.0
var skip_frame = false
var jump_is_bigger = false

signal character_attack
signal start_gesture

func _draw():
	pass

#movement
func _physics_process(delta):
	motion.y += GRAVITY
	if current_jump != null and not skip_frame:
		if jump_timer == 0.0:
			if null == $RayCast2D.get_collider():
				jump_is_bigger = false
			else:
				jump_is_bigger = true
		jump_timer += delta
		if jump_timer < current_jump.time_action:
			if jump_is_bigger:
				motion += current_jump.direction * current_jump.knock_power * current_jump.boost_factor
			else:
				motion += current_jump.direction * current_jump.knock_power
		else:
			current_jump = null
	else:
		skip_frame = false

	if current_jump == null :
		if(is_on_floor()):
		#if (abs(motion.x) > SPEED):
			motion *= 0
		#else:
			if Input.is_action_pressed("move_right"):
				motion.x = SPEED
			elif Input.is_action_pressed("move_left"):
				motion.x = -SPEED
		else:
			if (motion.x == 0.0):
				if Input.is_action_pressed("move_right"):
					motion.x = SPEED
				elif Input.is_action_pressed("move_left"):
					motion.x = -SPEED
			else:
				if Input.is_action_pressed("move_right"):
					motion.x += FLYING_ADJUST_SPEED
				elif Input.is_action_pressed("move_left"):
					motion.x -= FLYING_ADJUST_SPEED
			if (abs(motion.x) > MAX_FLYING_SPEED):
				motion.x = sign(motion.x) * MAX_FLYING_SPEED

	# move_and_slide already applie delta on motion, so we shouldn't do it beforehand
	motion = move_and_slide(motion, UP, false, 4, PI/4, true)


#keypress 
func _input(event):
	#show selection plate
	if Input.is_action_pressed("ctrl"):
		selection_plate.show()
		selection_plate.lighten_element(get_element_by_angle(get_mouse_angle()))

	if Input.is_action_just_released("ctrl"):
		selection_plate.hide()
		#$Sprite.play(get_element_by_angle(get_mouse_angle()))

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
				face_direction = 1
	elif Input.is_action_pressed("move_left"):
				$Sprite.flip_h = true
				face_direction = -1


#elements change 
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


#interfaces
func element_collected(type, amount):
	"""
	called when a  collectable element is collected
	"""
	# Add the amount of element type

	#index of element   0:Spring 1:Knife 2:Fire 3:Wood 4:Earth
	# TODO logic and assignments
	
	#var temp = get(type).current_amount + amount
	#get(type).current_amount = get(type).max_amount if temp > get(type).max_amount  else temp
	
	match type:
		0: 
			var temp = SPRING.current_amount + amount
			SPRING.current_amount = SPRING.max_amount if temp > SPRING.max_amount  else temp
		1:
			var temp = KNIFE.current_amount + amount
			KNIFE.current_amount = KNIFE.max_amount if temp > KNIFE.max_amount  else temp
		2:
			var temp = FIRE.current_amount + amount
			FIRE.current_amount = FIRE.max_amount if temp > FIRE.max_amount  else temp
		3:
			var temp = WOOD.current_amount + amount
			WOOD.current_amount = WOOD.max_amount if temp > WOOD.max_amount  else temp
		4:
			var temp = EARTH.current_amount + amount
			EARTH.current_amount = EARTH.max_amount if temp > EARTH.max_amount  else temp
	#print("COLLECTED: ", type, ", ", amount)


func _on_EnemyModel_attack(damage):
	get_node("Status/Health")._get_hit(damage)


func _ready():
	selection_plate.hide()
	element_handler = get_node("/root/"+get_tree().get_current_scene().get_name()+"/ElementHandler")
	element_handler.set_gravity(10)
	$FloatingHero.play("Floating")


func complete_gesture(gesture, button):
	if not gesture.line:
		return
	
	var action = Action.new()
	if button == 1:
		#print("complete left gesture")
		action.element = element_left
	else:
		#print("complete right gesture")
		action.element = element_right
				
	var elmt = ELEMENTS[action.element]
	action.face_direction = face_direction
	var angle_with_x = gesture.get_angle_with_x()
	match elmt:
		"Knife":
			element_handler.createElement(1, rand_range(0.5, 1), Vector2(position[0] + 20*face_direction + rand_range(-10, 10), position[1]+ rand_range(-10, 10)))
			if face_direction == -1:
				if angle_with_x <= PI/6 or angle_with_x > 11*PI/6:
					action.name = "Thrust"
				elif angle_with_x > PI/6 and angle_with_x <= PI/2:
					action.name = "Lift"
				elif angle_with_x >3*PI/2 and angle_with_x <= 11*PI/6:
					action.name = "Slash"
			else:
				if angle_with_x >= 5* PI/6 and angle_with_x < 7*PI/6:
					action.name = "Thrust"
				elif angle_with_x > PI/2 and angle_with_x <= 5*PI/6:
					action.name = "Lift"
				elif angle_with_x >7*PI/6 and angle_with_x <= 3*PI/2:
					action.name = "Slash"
			
		"Fire":
			element_handler.createElement(2, rand_range(0.5, 1), Vector2(position[0] + -20*face_direction + rand_range(-3, 3), position[1]))
			if face_direction == -1:
				if angle_with_x > PI/2 and angle_with_x <= 3*PI/2:
					action.name = "Arrow"
					action.direction = - gesture.get_direction()
				else:
					action.name = "Fireball"
					action.direction = gesture.get_direction()
			else:
				if angle_with_x > PI/2 and angle_with_x <= 3*PI/2:
					action.name = "Fireball"
					action.direction = gesture.get_direction()
				else:
					action.name = "Arrow"
					action.direction = - gesture.get_direction()
		"Spring":
			element_handler.createElement(0, rand_range(0.5, 1), Vector2(position[0] + rand_range(-3, 3), position[1]))
			action.name = "Fly"
			action.direction = - gesture.get_direction()
			
		"Wood":
			pass
		"Earth":
			pass
	if action.name == null:
		return
	action.load_data()
	action.face_direction = face_direction
	action.position = $Sprite.position
	if action.name == "Fly":
		move(action)
	elif action.name != null:
		attack(action)
		
func move(action:Action):
	jump_timer = 0.0
	current_jump = action
	skip_frame = true # To process raycast

func attack(attack:Action):
	emit_signal("character_attack", attack)
	#print("Action " + attack.name)
	#attack = _check_combo(attack)
	#attack.direction = direction
	#print("emit: " + attack.name)
	#attack.set_parameter("test", 42.51)
	#emit_signal("character_attack", attack)
	pass

func start_gesture(button):
	if button == 1:
		pass
		#print("start left gesture")
	else:
		pass
		#print("start right gesture")
	emit_signal("start_gesture", button)
	
export(float) var ATTACK_RANGE = 50.0
func _point_is_in_range(point:Vector2):
	return point.x > position.x - ATTACK_RANGE and point.x < position.x + ATTACK_RANGE \
	and point.y > position.y - ATTACK_RANGE and point.y < position.y + ATTACK_RANGE

