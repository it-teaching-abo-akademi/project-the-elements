extends KinematicBody2D

const UP = Vector2(0,-1)
var motion =Vector2()
enum {STATE_IDLE, STATE_ATTACK, STATE_FLY}
var state : int = STATE_IDLE
const SPEED = 60
const FLYING_SPEED = 8
const FLYING_ADJUST_SPEED = 3
const GRAVITY = 5
var burst = true
const BURST_SPEED = 80
const FUEL_CONSUME = 1
const BURST_FUEL_CONSUME = 20
var fuel : int = 2000



func _physics_process(delta):
	motion.y+=GRAVITY
	if state == STATE_FLY:
		if(burst):
			print("burst")
			burst = false
			motion += -get_local_mouse_position().normalized()*BURST_SPEED
			fuel -= BURST_FUEL_CONSUME
		else:
			motion += -get_local_mouse_position().normalized()*FLYING_SPEED
			fuel -= FUEL_CONSUME
		print(fuel)
		
	if(!is_on_floor() || state == STATE_FLY):
		if Input.is_action_pressed("ui_right"):
			motion.x += FLYING_ADJUST_SPEED
		elif Input.is_action_pressed("ui_left"):
			motion.x += -FLYING_ADJUST_SPEED

#if there is no flying effect
	else:
		if (abs(motion.x) > SPEED):
			motion*=0.95
		else:
			if Input.is_action_pressed("ui_right"):
				motion.x = SPEED
			elif Input.is_action_pressed("ui_left"):
				motion.x = -SPEED
			else:
				motion.x = 0
				
	motion = move_and_slide(motion,UP)
	pass
	

var attack_begin
var last_mouse_position
var attack_end
var coordinate_array = Array()
var frame_count : int = 0

func _input(event):

	
	if state == STATE_IDLE:
		if event is InputEventMouseButton && event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				attack_begin = get_global_mouse_position()
				#last_mouse_position = attack_begin
				#print(attack_begin)
				coordinate_array.append(attack_begin)
				state = STATE_ATTACK
			if event.button_index == BUTTON_RIGHT:
				state = STATE_FLY
				burst = true
	elif state == STATE_ATTACK:
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
			state = STATE_IDLE
			attack_end = get_global_mouse_position()
			coordinate_array.append(attack_end)
			attack(coordinate_array)
			coordinate_array.clear()
	elif state == STATE_FLY:
		#flying logic in the _physics_process function
		if event is InputEventMouseButton && (!event.is_pressed()) && event.button_index == BUTTON_RIGHT:
			state = STATE_IDLE

func attack(coordinate_array:Array):
	print(coordinate_array)
	pass
