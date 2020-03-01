extends KinematicBody2D

class_name Character

#element selection
onready var selection_plate = $SelectionPlate
onready var arrow_scene = preload("res://Elements/Arrow.tscn")
onready var fireball_scene = preload("res://Elements/Fireball.tscn")

const ELEMENTS = ["Spring", "Knife", "Fire", "Wood", "Earth"]
const ELEMENT_COLORS = [
	Color(0, 0.5, 1, 0.5), # Spring
	Color(0.96, 0.96, 0.96, 0.5), # Knife
	Color(0.86, 0.08, 0.24, 0.5), # Fire
	Color(0.2, 0.8, 0.2, 0.5), # Wood
	Color(0.82, 0.41, 0.12, 0.5), # Earth
]

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
onready var elements = get_node("Status/Elements")

#properties
var health
var defence
var element_left = 0 #index of element   0:Spring 1:Knife 2:Fire 3:Wood 4:Earth
var element_right = 1 #index of element   0:Spring 1:Knife 2:Fire 3:Wood 4:Earth
var face_direction : int = 1 # 1: look right, -1 left
var protected = false

var motion = Vector2()

var element_handler # Handles collectable elements
var mouse_effect

var current_jump = null
var jump_timer = 0.0
var skip_frame = false
var jump_is_bigger = false

signal character_attack
signal start_gesture
signal update_element_indicators

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

func magma():
	get_node("Status/Health")._get_hit(10)
	if(motion.y >= 0):
		motion.y = -200
	else:
		motion.y = 50

func thorn(direction):
	get_node("Status/Health")._get_hit(10)
	if(direction == 0):
		motion.y = -200
	else:
		motion.y = -150
		motion.x = direction * 200


#keypress 
func _input(event):
	#show selection plate
	#if Input.is_action_pressed("ctrl"):
		#selection_plate.show()
		#selection_plate.lighten_element(get_element_by_angle(get_mouse_angle()))

	#if Input.is_action_just_released("ctrl"):
		#selection_plate.hide()
		#$Sprite.play(get_element_by_angle(get_mouse_angle()))

	#change elements
	if Input.is_action_just_pressed("change_element_left_previous"):
		element_left = change_element_to_previous(element_left, element_right)
		update_element_indicators()
	if Input.is_action_just_pressed("change_element_left_next"):
		element_left = change_element_to_next(element_left, element_right)
		update_element_indicators()
	if Input.is_action_just_pressed("change_element_right_previous"):
		element_right = change_element_to_previous(element_right, element_left)
		update_element_indicators()
	if Input.is_action_just_pressed("change_element_right_next"):
		element_right = change_element_to_next(element_right, element_left)
		update_element_indicators()

	#flip sprite
	if Input.is_action_pressed("move_right"):
				$Sprite.flip_h = false
				face_direction = 1
	elif Input.is_action_pressed("move_left"):
				$Sprite.flip_h = true
				face_direction = -1
				
	#mouse pressed
	if Input.is_action_pressed("left_mouse_click"):
		generate_mouse_effect(element_left,get_global_mouse_position()-self.position)
	elif Input.is_action_pressed("right_mouse_click"):
		generate_mouse_effect(element_right,get_global_mouse_position()-self.position)


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
	elements.change_value(type, -amount)


func _on_EnemyModel_attack(attack : Action):
	if protected:
		protected = false
		return
	get_node("Status/Health")._get_hit(attack.damage)
	position.x += attack.face_direction * 30


func _ready():
	mouse_effect = preload("res://Attack/MouseEffect.tscn")
	var indicator = get_tree().get_current_scene().get_node("CanvasLayer/Indicators")
	connect("update_element_indicators",indicator,"_on_Player_update_element_indicators")
	update_element_indicators()
	#selection_plate.hide()
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
			#get_node("Status/Elements").change_value(1,10)
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
			if elements.change_value(action.element, action.element_consume) == false:
				return
			element_handler.createElement(action.element, action.element_consume, Vector2(position[0] + rand_range(-3, 3), position[1]))
		"Fire":
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
			if elements.change_value(action.element, action.element_consume) == false:
				return
			element_handler.createElement(action.element, action.element_consume, Vector2(position[0] + rand_range(-3, 3), position[1]))
		"Spring":
			action.name = "Fly"
			action.load_data()
			if elements.change_value(action.element, action.element_consume) == false:
				return
			element_handler.createElement(action.element, action.element_consume, Vector2(position[0] + rand_range(-3, 3), position[1]))
			action.direction = - gesture.get_direction()
			
		"Wood":
			action.name = "Recovery"
			action.load_data()
			if elements.change_value(action.element, action.element_consume) == false:
				return
			#element_handler.createElement(action.element, action.element_consume, Vector2(position[0] + rand_range(-3, 3), position[1]))
			get_node("Status/Health")._get_hit(action.damage)
			return
		"Earth":
			action.name = "Shield"
			action.load_data()
			if elements.change_value(action.element, action.element_consume) == false:
				return
			#element_handler.createElement(action.element, action.element_consume, Vector2(position[0] + rand_range(-3, 3), position[1]))
			protected = true
			return
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

func generate_mouse_effect(type, position):
	var effect = mouse_effect.instance()
	effect.position = position
	var particles = effect.get_node("Particles2D")
	particles.modulate = ELEMENT_COLORS[type]
	get_node("Camera2D").add_child(effect)
	particles.set_emitting(true)
	

func update_element_indicators():
	emit_signal("update_element_indicators",element_left, element_right) #index of element   0:Spring 1:Knife 2:Fire 3:Wood 4:Earth

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

