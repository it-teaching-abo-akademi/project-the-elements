extends KinematicBody2D

# This is the base class for enemies
class_name EnemyModelLift


# Variables
var speed = 5000
var strength = 5
var hp = 100
var max_hp = 100
var state
var velocity = Vector2.ZERO
var face_direction = 1
var element = 1

# Abilities
var player = null
var player_in_attack_range = null

var current_attack : Action = null

var attack_mode : Action = null

var timer = null

var state_machine

onready var element_handler = global.current_scene.get_node("ElementHandler")

signal timer_end

func _physics_process(delta):
	if state == global.ENEMY_STATES['IDLE']:
		velocity.y += global.GRAVITY * delta
		velocity.x = 0
		velocity = move_and_slide(velocity, global.UP)
	elif state == global.ENEMY_STATES['PATROL']:
		#chase()
		if player == null:
			if $RayCast2D.is_colliding() == false:
				face_direction = face_direction * -1
			velocity.x = face_direction * speed * delta * 0.5
		else:
			if $RayCast2D.is_colliding() == false:
				return
			velocity = (player.position - get_global_position()).normalized() * Vector2(1,0) * speed * delta
		velocity.y += global.GRAVITY * delta
		if velocity.x >= 0:
			$Sprite.flip_h = true
			face_direction = 1
		else:
			$Sprite.flip_h = false
			face_direction = -1
		velocity = move_and_slide(velocity,global.UP)
	elif state == global.ENEMY_STATES['LIFT']:
		if current_attack == null:
			state = global.ENEMY_STATES['PATROL']
			return
		position.x += current_attack.face_direction * 30
		position.y -= 20
		current_attack = null
		state = global.ENEMY_STATES['PATROL']
	elif state == global.ENEMY_STATES['ATTACK']:
		if attack_mode == null:
			state = global.ENEMY_STATES['PATROL']
			return
		velocity.x = 0
		velocity.y += global.GRAVITY * delta
		velocity = move_and_slide(velocity,global.UP)
		attack_mode.face_direction = face_direction
		var str_direction
		if face_direction == 1:
			str_direction = "_right"
		else:
			str_direction = "_left"
		state_machine.travel(attack_mode.name+"_generate"+str_direction)
		state = global.ENEMY_STATES['IDLE']
		wait(3)
		yield(self, "timer_end")
		timer.queue_free()
		if player_in_attack_range == null:
			state = global.ENEMY_STATES['PATROL']
		else:
			state = global.ENEMY_STATES['ATTACK']
func _ready():
	state_machine = get_node("AttackSystem/AnimationTree").get("parameters/playback")
	state_machine.start("Await")
	_init()

# Instantiation, to be extended by subclasses
func _init():
	speed = rand_range(4500,5500)
	strength = rand_range(4, 6)
	max_hp = rand_range(80, 120)
	hp = max_hp
	state = global.ENEMY_STATES['PATROL']
	velocity = Vector2.ZERO
	attack_mode = Action.new()
	attack_mode.name = "Lift"
	attack_mode.load_data()

func wait(time):
	timer = Timer.new()
	timer.set_wait_time(time)
	timer.set_one_shot(true)
	timer.connect("timeout",self,"_emit_timer_end_signal")
	self.add_child(timer)
	timer.start()
	

func _emit_timer_end_signal():
    emit_signal("timer_end")
	
func _on_Player_weapon_attack(attack : Action):
	# The player attacked. We need to check here if the current monster is hurt
	# TODO: the check is just for debug, it needs to be improved
	hp -= attack.damage
	current_attack = attack
	state = global.ENEMY_STATES['LIFT']
	var hero = global.current_scene.get_node('Player')
	if hp <= 0:
		element_handler.createElement(element, 10, Vector2(hero.position[0] + rand_range(-3, 3), hero.position[1]))
		queue_free()
		#get_node("CollisionShape2D").disabled = true
	pass


func _on_Detect_range_body_entered(body):
	if "Player" in body.name:
		player = global.current_scene.get_node('Player')


func _on_Detect_range_body_exited(body):
	if "Player" in body.name:
		player = null


func _on_Attack_range_body_entered(body):
	if "Player" in body.name:
		player_in_attack_range = player
		state = global.ENEMY_STATES['ATTACK']


func _on_Attack_range_body_exited(body):
	if "Player" in body.name:
		player_in_attack_range = null


func _on_Wall_detect_body_entered(body):
	if "Tile" in body.name:
		face_direction = face_direction * -1
