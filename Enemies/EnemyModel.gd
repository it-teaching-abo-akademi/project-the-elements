extends KinematicBody2D

# This is the base class for enemies
class_name EnemyModel

# Variables
var speed = 5000
var strength = 5
var hp = 100
var max_hp = 100
var detection_range = 200
var attack_range = 10
var preferred_attack_range = 10
var state
var velocity

# Abilities
var canCooperate = false
var canFly = false
var canDetectFlyingHero = false
var canMove = true
var player

onready var character_body : Character = get_tree().get_current_scene().get_node('Player')

var previous_state
var current_attack = null
var time_counter = 0

func _set_state(new_state):
	# We can do whatever with the previous state here
	previous_state = state
	state = new_state

func _physics_process(delta):
	if state == global.ENEMY_STATES['PATROL']:
		# print("ici")
		#chase()
		pass
		if player:
			velocity = (player.position - position).normalized() * speed * delta
			velocity.y += global.GRAVITY * delta
		else:
			#code here
			velocity = Vector2.ZERO
		if velocity.x >= 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		velocity = move_and_slide(velocity)
	elif state == global.ENEMY_STATES['KNOCK']:
		# Normal knock
		# Heavy slash
		# Lunge
		# Sword wave
		time_counter += delta
		if current_attack.get_parameter("time_before") != 0:
			if time_counter > current_attack.get_parameter("time_before"):
				time_counter = 0
				current_attack.set_parameter("time_before", 0.0)
		elif current_attack.get_parameter("time_attack") != 0:
			velocity.y = global.GRAVITY
			velocity.x += speed * delta
			velocity = move_and_slide(velocity)
			if time_counter > current_attack.get_parameter("time_attack"):
				time_counter = 0
				current_attack.set_parameter("time_attack", 0.0)
		elif current_attack.get_parameter("time_after") != 0:
			velocity = Vector2.ZERO
			if time_counter > current_attack.get_parameter("time_after"):
				time_counter = 0
				current_attack.set_parameter("time_after", 0.0)
				_set_state(previous_state)
		else:
			time_counter = 0
			current_attack.set_parameter("time_after", 0.0)
			_set_state(previous_state)
	elif state == global.ENEMY_STATES['LIFT']:
		# Normal lift
		# 180° lift
		# fast lift
		# higher lift
		time_counter += delta
		if current_attack.get_parameter("time_before") != 0:
			if time_counter > current_attack.get_parameter("time_before"):
				time_counter = 0
				current_attack.set_parameter("time_before", 0.0)
		elif current_attack.get_parameter("time_attack") != 0:
			if current_attack.get_parameter("combo_effect") == 6:
				# Faster lift
				current_attack.set_parameter("time_attack", current_attack.get_parameter("time_attack") / 2.0)
				velocity.y = -speed * delta * 2.0
			elif current_attack.get_parameter("combo_effect") == 8:
				# Higher lift
				velocity.y = -speed * delta * 1.5
			else:
				# Normal lift
				velocity.y = -speed * delta
			velocity.x = 0
			if time_counter > current_attack.get_parameter("time_attack") / 2.0:
				# 180°
				velocity.x = 200
			velocity = move_and_slide(velocity)
			if time_counter > current_attack.get_parameter("time_attack"):
				time_counter = 0
				current_attack.set_parameter("time_attack", 0.0)
		elif current_attack.get_parameter("time_after") != 0:
			velocity.y = global.GRAVITY * delta
			velocity.x = 0
			velocity = move_and_slide(velocity)
			if time_counter > current_attack.get_parameter("time_after"):
				time_counter = 0
				current_attack.set_parameter("time_after", 0.0)
				_set_state(previous_state)
		else:
			time_counter = 0
			current_attack.set_parameter("time_after", 0.0)
			_set_state(previous_state)
func _ready():
	_init()
	

# Instantiation, to be extended by subclasses
func _init():
	speed = rand_range(4500,5500)
	strength = rand_range(4, 6)
	max_hp = rand_range(80, 120)
	hp = max_hp
	state = global.ENEMY_STATES['PATROL']
	
	velocity = Vector2.ZERO

func chase():
	pass








func _on_Player_character_attack(attack):
	# The player attacked. We need to check here if the current monster is hurt
	# TODO: the check is just for debug, it needs to be improved
	
	if position.x < attack.get_parameter("start_position").x + attack.get_parameter("range_effect"):
		current_attack = attack
		print("Damage done: " + str(attack.get_parameter("damage")))
		
		if attack.get_parameter("name") == "Thrust":
			_set_state(global.ENEMY_STATES['KNOCK'])


func _on_Detect_range_body_entered(body):
	if "Player" in body.name:
		player = character_body


func _on_Detect_range_body_exited(body):
	if "Player" in body.name:
		player = null


func _on_Attack_range_body_entered(body):
	pass # Replace with function body.


func _on_Attack_range_body_exited(body):
	pass # Replace with function body.
