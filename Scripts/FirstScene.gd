extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {STATE_IDLE, STATE_ATTACK, STATE_FLY}
var state : int = STATE_IDLE

func _input(event):
	if state == STATE_IDLE:
		if event is InputEventMouseButton && event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				state = STATE_ATTACK
			if event.button_index == BUTTON_RIGHT:
				state = STATE_FLY
	elif state == STATE_ATTACK:
		if event is InputEventMouseMotion:
			print("Attacking mode:", event.position)
			#分辨近战远程
			#攻击处理
		if event is InputEventMouseButton && (!event.is_pressed()) && event.button_index == BUTTON_LEFT:
			state = STATE_IDLE
	elif state == STATE_FLY:
		if event is InputEventMouseMotion:
			print("Flying mode:", event.position)
			#飞行处理
		if event is InputEventMouseButton && (!event.is_pressed()) && event.button_index == BUTTON_RIGHT:
			state = STATE_IDLE
