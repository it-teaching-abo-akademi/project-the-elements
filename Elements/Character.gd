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

var element_handler # Handles collectable elements

#element selection
onready var selection_plate = $SelectionPlate

var direction = 1 # 1: look right, -1 left

#temp var
var element_look = 0

class_name Character

signal start_gesture

# Parameter: Action, element
signal character_attack

# List of attack names, to check if there is a combo
var combo_list = []

onready var arrow_scene = preload("res://Elements/Arrow.tscn")
onready var fireball_scene = preload("res://Elements/Fireball.tscn")

var current_jump = null
var jump_timer = 0.0

func _draw():
	pass

func _physics_process(delta):
	motion.y += GRAVITY
	#$Sprite.play(ELEMENTS[element_look])
	motion.x = lerp(motion.x, 0, friction)

	if current_jump != null:
		jump_timer += delta
		if jump_timer < current_jump.get_parameter("time_jumping"):
			motion += current_jump.get_parameter("direction") * current_jump.get_parameter("power")
		else:
			current_jump = null

#	if state == global.CHARACTER_STATES['STATE_FLY']:
#		if(burst):
#			# print("burst")
#			burst = false
#			motion += -get_local_mouse_position().normalized() * BURST_SPEED
#			fuel -= BURST_FUEL_CONSUME
#		else:
#			motion += -get_local_mouse_position().normalized() * FLYING_SPEED
#			fuel -= FUEL_CONSUME
#		# print(fuel)

#	if(!is_on_floor() || state == global.CHARACTER_STATES['STATE_FLY']):
#		if Input.is_action_pressed("move_right"):
#			motion.x += FLYING_ADJUST_SPEED * delta
#		elif Input.is_action_pressed("move_left"):
#			motion.x += -FLYING_ADJUST_SPEED * delta
#		#$Sprite.play("Jump")
#	else: #if there is no flying effect
	if current_jump == null:
		if (abs(motion.x) > SPEED):
			motion *= 0.95
		else:
			if Input.is_action_pressed("move_right"):
				motion.x = SPEED
			elif Input.is_action_pressed("move_left"):
				motion.x = -SPEED

	# move_and_slide already applie delta on motion, so we shouldn't do it beforehand
	motion = move_and_slide(motion, UP, false, 4, PI/4, true)

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
				direction = 1
	elif Input.is_action_pressed("move_left"):
				$Sprite.flip_h = true
				direction = -1

	#temp
	if Input.is_action_just_pressed("space"):
		element_look = change_element_to_next(element_look, 6)

#	if state == global.CHARACTER_STATES['STATE_IDLE']:
#		if Input.is_action_pressed("left_mouse_click"):
#			if ELEMENTS[element_left] == 'Spring':
#				state = global.CHARACTER_STATES['STATE_FLY']
#				burst = true
#			else:
#				state = global.CHARACTER_STATES['STATE_ATTACK']
#				print(ELEMENTS[element_left])
#				attack_begin = get_global_mouse_position()
#				#last_mouse_position = attack_begin
#				#print(attack_begin)
#				coordinate_array.append(attack_begin)
#				state = global.CHARACTER_STATES['STATE_IDLE']
#		if Input.is_action_pressed("right_mouse_click"):
#			if ELEMENTS[element_right] == 'Spring':
#				state = global.CHARACTER_STATES['STATE_FLY']
#				burst = true
#			else:
#				state = global.CHARACTER_STATES['STATE_ATTACK']
#				print(ELEMENTS[element_right])
#				attack_begin = get_global_mouse_position()
#				#last_mouse_position = attack_begin
#				#print(attack_begin)
#				coordinate_array.append(attack_begin)
#				state = global.CHARACTER_STATES['STATE_IDLE']
#	elif state == global.CHARACTER_STATES['STATE_ATTACK']:
#		#attacking mode detection here
#
#		#
#		if event is InputEventMouseMotion:
#			frame_count+=1
#			if(frame_count == 5):
#				frame_count = 0
#				coordinate_array.append(get_global_mouse_position())
#			#print("Actioning mode:", event.position)
#			#last_mouse_position = get_global_mouse_position()
#			#some manipulation here
#		if Input.is_action_pressed("left_mouse_click"):
#			state = global.CHARACTER_STATES['STATE_IDLE']
#			attack_end = get_global_mouse_position()
#			coordinate_array.append(attack_end)
#			# attack(coordinate_array)
#			coordinate_array.clear()
#	if state == global.CHARACTER_STATES['STATE_FLY'] and Input.is_action_just_released("left_mouse_click"):
#		#flying logic in the _physics_process function
#		state = global.CHARACTER_STATES['STATE_IDLE']


func _check_combo(attack:Action):
	"""
	Check if there is a combo, and if there is,
	update the Action object and return it
	"""

	combo_list.append(attack.get_parameter("name"))

	# If there is a combo, we don't try to check others
	if combo_list.size() >= 3:
		# Check size 3 combo
		var three = combo_list[combo_list.size() - 1]
		var two = combo_list[combo_list.size() - 2]
		var one = combo_list[combo_list.size() - 3]

		if one == "Thrust" and two == "Thrust" and three == "Thrust":
			# Lunge
			attack.combo_effect = 1
			combo_list.clear()
			print("ATTACK: combo lunge")
			return attack
		elif one == "Thrust" and two == "Thrust" and three == "Slash":
			# Sword wave (sword intent)
			attack.combo_effect = 2
			combo_list.clear()
			print("ATTACK: combo sword wave")
			return attack
	if combo_list.size() >= 2:
		var two = combo_list[combo_list.size() - 1]
		var one = combo_list[combo_list.size() - 2]

		# Check size 2 combo
		if one == "Lift" and two == "Arrow":
			# Arrow power up: +speed +damage
			attack.combo_effect = 3
			combo_list.clear()
			print("ATTACK: combo arrow power up")
			return attack
		elif (one == "Lift" and two == "Slash") or (one == "Thrust" and two == "Slash"):
			# Heavy slash
			attack.combo_effect = 4
			combo_list.clear()
			print("ATTACK: combo heavy slash")
			return attack
		elif one == "Lift" and two == "Lift":
			# Special lift
			attack.combo_effect = 5
			combo_list.clear()
			print("ATTACK: combo special lift")
			return attack
		elif one == "Thrust" and two == "Lift":
			# Fast lift
			attack.combo_effect = 6
			print("ATTACK: combo fast lift")
			return attack
		elif one == "Slash" and two == "Thrust":
			# Laijutsu
			attack.combo_effect = 7
			combo_list.clear()
			print("ATTACK: combo laijustsu")
			return attack
		elif one == "Slash" and two == "Lift":
			# Higher lift
			attack.combo_effect = 8
			combo_list.clear()
			print("ATTACK: combo higher lift")
			return attack

	return attack

func move(action:Action):
	jump_timer = 0.0
	current_jump = action

func attack(attack:Action):
	print("Action " + attack.get_parameter("name"))

	attack = _check_combo(attack)
	
	
	attack.direction = direction
	print("emit: " + attack.get_parameter("name"))
	attack.set_parameter("test", 42.51)
	emit_signal("character_attack", attack)
		element_handler.createElement(2, rand_range(0.5, 1), Vector2(position[0] + 100 + rand_range(-3, 3), position[1]))

#	var animator = null
#	if attack.get_parameter("name") == "Slash":
#		# animator = $SwordAnimations
#		$Weapon.display_attack($Weapon.WEAPON_KATANA, direction)
#	elif attack.get_parameter("name") == "Thrust":
#		# animator = $SpearAnimations
#		$Weapon.display_attack($Weapon.WEAPON_SPEAR, direction)
#	elif attack.get_parameter("name") == "Arrow":
#		var arrow_instance = arrow_scene.instance()
#		# arrow_instance.position = position
#		# arrow_instance.linear_velocity.x = 1000
#		arrow_instance.linear_velocity = attack.points[1].direction_to(attack.points[0]) * 1000
#		arrow_instance.position = to_local(attack.start_position)
#		add_child(arrow_instance)
#	elif attack.get_parameter("name") == "Fireball":
#		var fireball_instance = fireball_scene.instance()
#		# fireball_instance.linear_velocity.x = 1000
#		fireball_instance.linear_velocity = attack.points[0].direction_to(attack.points[1]) * 1000
#		fireball_instance.position = to_local(attack.start_position)
#		add_child(fireball_instance)
#
#	if animator:
#		animator.play("Appear")
#		animator.queue("Action")
#		animator.queue("Disappear")

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

	var attack = Action.new()
	if button == 1:
		attack.element = element_left
	else:
		attack.element = element_right

	if gesture.points[0].distance_squared_to(gesture.points.back()) < MINIMUM_LINE_LENGTH * MINIMUM_LINE_LENGTH:
		return

	var elmt = ELEMENTS[attack.element]
	if elmt == "Knife":
		if (direction == 1 and gesture.direction == global.DIRECTION['DIR_SE']) or (direction == -1 and gesture.direction == global.DIRECTION['DIR_SW']):
			attack.set_parameter("name", "Slash")
			attack.set_parameter("damage", 42.0)
			attack.set_parameter("start_position", position)
			attack.set_parameter("range_effect", 100.0)
			attack.set_parameter("time_before", 0.15)
			attack.set_parameter("time_attack", 0.25)
			attack.set_parameter("time_after", 0.3)
		elif (direction == 1 and gesture.direction == global.DIRECTION['DIR_E']) or (direction == -1 and gesture.direction == global.DIRECTION['DIR_W']):
			attack.set_parameter("name", "Thrust")
			attack.set_parameter("damage", 18.0)
			attack.set_parameter("start_position", position)
			attack.set_parameter("range_effect", direction * 200.0)
			attack.set_parameter("time_before", 0.1)
			attack.set_parameter("time_attack", 0.15)
			attack.set_parameter("time_after", 1.0)
		elif (direction == 1 and gesture.direction == global.DIRECTION['DIR_NE']) or (direction == -1 and gesture.direction == global.DIRECTION['DIR_NW']):
			attack.set_parameter("name", "Lift")
			attack.set_parameter("damage", 5.0)
			attack.set_parameter("start_position", position)
			attack.set_parameter("time_before", 0.2)
			attack.set_parameter("time_attack", 0.5)
			attack.set_parameter("time_after", 0.5)
	elif elmt == "Fire":
		# Fireball
		# Arrow
		# if the line is in direction of the player, it's an arrow. Else it's a fireball
		if position.distance_squared_to(gesture.points[0]) > position.distance_squared_to(gesture.points.back()):
			# Direction of the player
#			attack.get_parameter("name") = "Arrow"
#			attack.damage = 10.0
#			attack.start_position = position
#			attack.start_position.x += direction * 75
#			attack.points.append(gesture.points[0])
#			attack.points.append(gesture.points.back())
			pass
		else:
			pass
#			attack.get_parameter("name") = "Fireball"
#			attack.damage = 15.0
#			attack.start_position = position
#			attack.start_position.x += direction * 75
#			attack.points.append(gesture.points[0])
#			attack.points.append(gesture.points.back())

		# Rain of arrows (maybe later)
	elif elmt == "Spring":
		attack.set_parameter("name", "Fly")
		attack.set_parameter("direction", gesture.points.back().direction_to(gesture.points[0]))
		attack.set_parameter("power", 70.0)
		attack.set_parameter("time_jumping", .25)
		attack.set_parameter("element_used", 10.0)
	elif elmt == "Wood":
		# Action anywhere, not really designed yet
		pass
	elif elmt == "Earth":
		# Create a shield
		pass

	if attack.get_parameter("name") == "Fly" or attack.get_parameter("name") == "Jump":
		move(attack)
	elif attack.get_parameter("name") != null:
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


enum {WATER, KNIFE, FIRE, WOOD, SOIL}
func element_collected(type, amount):
	"""
	called when a  collectable element is collected
	"""
	# Add the amount of element type

	# TODO logic and assignments
	if type == WATER:
		fuel += floor(amount*100)
	# elif type == KNIFE:
	# elif type == FIRE:
	# elif type == WOOD:
	# elif type == SOIL:

	print("COLLECTED: ", type, ", ", amount)

func _ready():
	selection_plate.hide()
	element_handler = get_node("/root/"+get_tree().get_current_scene().get_name()+"/ElementHandler")
	element_handler.set_gravity(10)
	# Create gestures
	# Eventually it should be loaded from a file
	# var attack = Action.new()
	# attack.damage = 42.0
	# attack.get_parameter("name") = 'Random name'

	# var gesture = Gesture.new(1.0, [Vector2(-100,-100), Vector2(100,100)])
	# gesture.radius = 25.0
	# gesture.attack = attack

	# $DrawDetector.add_gesture(gesture)
	pass
