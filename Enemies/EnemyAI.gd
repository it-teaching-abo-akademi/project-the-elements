extends KinematicBody2D

# This is the base class for enemies
class_name EnemyAI

var UP = global.UP
var GRAVITY = global.GRAVITY
var isEnemy = true

# Variables
var speed = 5000
var strength = 5
var hp = 100
var max_hp = 100
var motion_state # SLEEP, PATROL, CHASE, KNOCK, LIFT
var last_motion_state
var logic_state # ATTACK, DEAD, IDLE
var motion = Vector2()
var face_direction = 1
var element = 1
# Abilities
var player = null
var player_in_attack_range = null

var current_attack : Action = null

var attack_mode : Action = null

var state_machine

var sleep_timer = 0.5
var patrol_timer = 3.5
var knockback_timer = 0.5
var liftup_timer = 0.5
var cd = 4 # attack cd

onready var element_handler = get_tree().get_current_scene().get_node("ElementHandler")


func _physics_process(delta):
	$RayCast2D.rotation_degrees = -face_direction * 25
	$RayCast2D2.rotation_degrees = -face_direction * 90
	motion.y += GRAVITY
	#print(motion_state)
	match motion_state:
		0: #sleep
			sleep_timer += delta
			motion.x = 0
			if(sleep_timer > 0.5):
				motion_state = 1
				sleep_timer = 0
		1: #patrol
			if $RayCast2D.is_colliding() == false:
				motion_state = 3
				motion.x = 0
			else:
				patrol_timer += delta
				motion.x = face_direction * speed * delta * 0.5
				if(patrol_timer > 3.5):
					motion_state = 3
					patrol_timer = 0
		2: #chase
			if (($RayCast2D.is_colliding() == false)||($RayCast2D2.is_colliding() == true)):
				motion.x = 0
			else:
				if player.position.x >= to_global($Sprite.position).x:
					face_direction = 1
					$Sprite.flip_h = true
				else:
					face_direction = -1
					$Sprite.flip_h = false
				motion.x = face_direction * speed * delta * 0.7
		3: #turn
			patrol_timer = 0
			turn_aroud()
			motion_state = 0
		4: #isknocked
			knockback_timer += delta
			move_and_collide(UP*current_attack.knock_power*delta)
			move_and_collide(Vector2(current_attack.face_direction,0)*current_attack.knock_power*80*delta)
			if knockback_timer > current_attack.knock_power/2:
				motion_state = last_motion_state
				current_attack = null
			return
		5: #islifted
			liftup_timer += delta
			move_and_collide(UP*current_attack.knock_power*80*delta)
			move_and_collide(Vector2(current_attack.face_direction,0)*current_attack.knock_power*20*delta)
			if liftup_timer > current_attack.knock_power/2:
				motion_state = last_motion_state
				current_attack = null
			return
	motion = move_and_slide(motion, UP, false, 4, PI/4, true)

func _process(delta):
	match logic_state:
		0: #attack
			cd += delta
			face_to_player()
			attack_mode.face_direction = face_direction
			match attack_mode.name:
				'Arrow':
					if(cd > 3):
						fire_arrow()
						cd = 0
				'Fireball':
					if(cd > 3):
						fire_ball()
						cd = 0
				'Lift','Thrust','Slash':
					if(cd > 1.5):
						melee_attack()
						cd = 0
		1: #idle
			pass

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
	motion_state = global.ENEMY_MOTION_STATES['SLEEP']
	logic_state = global.ENEMY_LOGIC_STATES['IDLE']

func set_status(SPE,STR,HP):
	speed = rand_range(SPE-500,SPE+500)#5000
	strength = rand_range(STR-1,STR+1)#5
	max_hp = rand_range(HP-20,HP+20)#100
	hp = max_hp

func turn_aroud():
	$Sprite.flip_h = not $Sprite.flip_h
	face_direction = -face_direction

func face_to_player():
	if to_global($Sprite.position).x - player_in_attack_range.position.x < 0:
		$Sprite.flip_h = true
		face_direction = 1
	else:
		$Sprite.flip_h = false
		face_direction = -1

func melee_attack():
	var str_direction
	if face_direction == 1:
		str_direction = "_right"
	else:
		str_direction = "_left"
	state_machine.travel(attack_mode.name+"_generate"+str_direction)

func fire_ball():
	var fireball_instance = global.fireball_scene.instance()
	player = global.current_scene.get_node('Player')
	var direction = (- to_global($Sprite.position) + player.position).normalized()
	fireball_instance.linear_velocity = direction * 500
	fireball_instance.position = to_global($Sprite.position)
	fireball_instance.position.x += face_direction * 20
	fireball_instance.rotation = direction.angle()
	fireball_instance.scale.x = face_direction
	fireball_instance.add_collision_exception_with(self)
	get_tree().get_current_scene().add_child(fireball_instance)

func fire_arrow():
	player = global.current_scene.get_node('Player')
	var arrow_instance = global.arrow_scene.instance()
	var direction = (- to_global($Sprite.position) + player.position).normalized()
	arrow_instance.linear_velocity = direction * 600
	arrow_instance.position = to_global($Sprite.position)
	arrow_instance.position.x += face_direction * 20
	arrow_instance.rotation = direction.angle()
	arrow_instance.scale.x = face_direction
	arrow_instance.add_collision_exception_with(self)
	get_tree().get_current_scene().add_child(arrow_instance)

func attack_once():
	match attack_mode.name:
		'Arrow':
			fire_arrow()
		'Fireball':
			fire_ball()
		'Lift','Thrust','Slash':
			melee_attack()


func _on_Player_weapon_attack(attack : Action):
	# The player attacked. We need to check here if the current monster is hurt
	# TODO: the check is just for debug, it needs to be improved
	current_attack = attack
	if current_attack.name.begins_with('Thrust') && motion_state != global.ENEMY_MOTION_STATES['ISKNOCKED']:
		last_motion_state = motion_state
		motion_state = global.ENEMY_MOTION_STATES['ISKNOCKED']
		knockback_timer = 0
	elif current_attack.name.ends_with('ift') && motion_state != global.ENEMY_MOTION_STATES['ISLIFTED']:
		last_motion_state = motion_state
		motion_state = global.ENEMY_MOTION_STATES['ISLIFTED']
		liftup_timer = 0
	hp -= current_attack.damage
	
	if hp <= 0:
		element_handler.createElement(element, 10, self.position)
		queue_free()
		#get_node("CollisionShape2D").disabled = true
	pass


func _on_Detect_range_body_entered(body):
	if "Player" in body.name:
		player = global.current_scene.get_node('Player')
		motion_state = global.ENEMY_MOTION_STATES['CHASE']


func _on_Detect_range_body_exited(body):
	if "Player" in body.name:
		player = null
		motion_state = global.ENEMY_MOTION_STATES['PATROL']


func _on_Attack_range_body_entered(body):
	if "Player" in body.name:
		player_in_attack_range = player
		logic_state = global.ENEMY_LOGIC_STATES['ATTACK']


func _on_Attack_range_body_exited(body):
	if "Player" in body.name:
		player_in_attack_range = null
		logic_state = global.ENEMY_LOGIC_STATES['IDLE']


func _on_Wall_detect_body_entered(body):
	if "Tile" in body.name:
		last_motion_state = motion_state
		motion_state = global.ENEMY_MOTION_STATES['TURN']
