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

func _physics_process(delta):
	if state == global.ENEMY_STATES['PATROL']:
		#chase()
		pass
		if player:
			velocity = (player.position - position).normalized() * speed * delta
			velocity.y = 0
		else:
			#code here
			velocity = Vector2.ZERO
		if velocity.x >= 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		velocity = move_and_slide(velocity)


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








func _on_Player_character_attack(attack:Attack):
	# The player attacked. We need to check here if the current monster is hurt
	# TODO: the check is just for debug, it needs to be improved
	if position.x < attack.start_position.x + attack.range_effect:
		print("Damage done: " + str(attack.damage))


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
