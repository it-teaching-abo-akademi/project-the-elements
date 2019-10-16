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


var fuel : int = 2000
var burst = true
var state = global.CHARACTER_STATES['STATE_IDLE']
var motion = Vector2()


class_name Character

func _physics_process(delta):
	motion.y += GRAVITY
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
		$Sprite.play("Jump")
	else: #if there is no flying effect
		if (abs(motion.x) > SPEED):
			motion *= 0.95
		else:
			if Input.is_action_pressed("move_right"):
				motion.x = SPEED
				$Sprite.flip_h = false
				$Sprite.play("Run")
			elif Input.is_action_pressed("move_left"):
				motion.x = -SPEED
				$Sprite.flip_h = true
				$Sprite.play("Run")
			else:
				motion.x = 0
				$Sprite.play("Idle")
	motion = move_and_slide(motion,UP)
	pass
	

var attack_begin
var last_mouse_position
var attack_end
var coordinate_array = Array()
var frame_count : int = 0

func _input(event):

	
	if state == global.CHARACTER_STATES['STATE_IDLE']:
		if event is InputEventMouseButton && event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				attack_begin = get_global_mouse_position()
				#last_mouse_position = attack_begin
				#print(attack_begin)
				coordinate_array.append(attack_begin)
				state = global.CHARACTER_STATES['STATE_ATTACK']
			if event.button_index == BUTTON_RIGHT:
				state = global.CHARACTER_STATES['STATE_FLY']
				burst = true
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
		if event is InputEventMouseButton && (!event.is_pressed()) && event.button_index == BUTTON_LEFT:
			state = global.CHARACTER_STATES['STATE_IDLE']
			attack_end = get_global_mouse_position()
			coordinate_array.append(attack_end)
			attack(coordinate_array)
			coordinate_array.clear()
	elif state == global.CHARACTER_STATES['STATE_FLY']:
		#flying logic in the _physics_process function
		if event is InputEventMouseButton && (!event.is_pressed()) && event.button_index == BUTTON_RIGHT:
			state = global.CHARACTER_STATES['STATE_IDLE']

func attack(coordinate_array:Array):
	print(coordinate_array)
	pass

