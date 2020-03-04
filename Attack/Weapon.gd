extends Node2D

class_name Weapon

const STATE_HIDED = 0
const STATE_APPEAR = 1
const STATE_VISBLE = 2
const STATE_DISAPPEAR = 3
const STATE_ATTACK = 4

var state = STATE_HIDED

var first_attack = null
var second_attack = null
var recent_attack = null
var current_attack = null

var appear_time = 0.0
var disappear_time = 0.0
var attack_time = 0.0

var timer = null
# 1 -> right ; -1 -> left
var direction = 1
var str_direction

var state_machine

signal launch_attack

onready var root = get_tree().get_current_scene()
onready var enemies = get_tree().get_current_scene().get_node('Enemies')
onready var elements = get_tree().get_current_scene().get_node("Player/Status/Elements")
onready var arrow_scene = preload("res://Elements/Arrow.tscn")
onready var fireball_scene = preload("res://Elements/Fireball.tscn")
onready var element_handler = get_tree().get_current_scene().get_node("ElementHandler")
onready var player = get_tree().get_current_scene().get_node("Player")

func display_attack(attack:Action):
	if attack == null:
		return
	current_attack = attack
	_re_init()


func _re_init():
	var sprite = $Sprite
	sprite.position = Vector2(0.0, 0.0)
	sprite.scale.x = abs(sprite.scale.x)
	sprite.rotation = 0.0
	rotation = 0.0
	position = Vector2(0.0, 0.0)
	scale.x = abs(scale.x)


func _process(delta):
	if current_attack == null:
		return
	if current_attack.face_direction == 1:
		str_direction = "_right"
	else:
		str_direction = "_left"
	match first_attack:
		null:
			#是什么技能就用什么技能
			basic_attack()
			record_attack(current_attack)
		"Lift":
			match current_attack.name:
				"Arrow":
					print("Arrow power up")
					clear_record()
				"Slash":
					print("Heavy slash")
					current_attack.name = "HeavySlash"
					if can_attack() == false:
						return
					state_machine.travel("HeavySlash_generate"+str_direction)
					clear_record()
				"Lift":
					print("180 lift")
					current_attack.name = "PowerLift"
					if can_attack() == false:
						return
					state_machine.travel("180Lift_generate"+str_direction)
					clear_record()
				_:
					#不为连招，重新记录
					basic_attack()
					clear_record()
					record_attack(current_attack)
		"Thrust":
			match second_attack:
				null:
					match current_attack.name:
						"Lift":
							print("Fast lift")
							current_attack.name = "Lift"
							if can_attack() == false:
								return
							state_machine.travel("FastLift_act"+str_direction)
							clear_record()
						"Thrust":
							print("Thrust2")
							current_attack.name = "Thrust"
							if can_attack() == false:
								return
							state_machine.travel("Thrust_act"+str_direction+" 2")
							record_attack(current_attack)
						_:
							#不为连招，重新记录
							basic_attack()
							clear_record()
							record_attack(current_attack)
				"Thrust":
					match current_attack.name:
						"Thrust":
							print("TripleThrust")
							current_attack.name = "TripleThrust"
							if can_attack() == false:
								return
							state_machine.travel("ThrustX3_act"+str_direction)
							clear_record()
						"Slash":
							print("Sword wave")
							current_attack.name = "SwordWave"
							if can_attack() == false:
								return
							state_machine.travel("SwordWave_act"+str_direction)
							clear_record()
						_:
							#不为连招，重新记录
							basic_attack()
							clear_record()
							record_attack(current_attack)
		"Slash":
			match current_attack.name:
				"Thrust":
					print("Laijutsu")
					current_attack.name = "Laijutsu"
					if can_attack() == false:
						return
					state_machine.travel("Laijutsu_act"+str_direction)
					clear_record()
				"Lift":
					print("Short lift")
					current_attack.name = "Lift"
					if can_attack() == false:
						return
					state_machine.travel("ShortLift_act"+str_direction)
					clear_record()
				_:
					#不为连招，重新记录
					basic_attack()
					clear_record()
					record_attack(current_attack)
		_:
			#不为连招，重新记录
			basic_attack()
			clear_record()
			record_attack(current_attack)
	#emit_signal("launch_attack", current_attack)
	recent_attack = current_attack
	current_attack = null

func record_attack(attack:Action):
	if first_attack == null:
		first_attack = attack.name
	elif second_attack == null:
		second_attack = attack.name
	count_time()

func clear_record():
	first_attack = null
	second_attack = null

func count_time():
	if timer == null:
		timer = Timer.new()
		timer.set_wait_time(3)
		timer.set_one_shot(true)
		self.add_child(timer)
		timer.start()
		yield(timer, "timeout")
		timer.queue_free()
		timer = null
		clear_record()
	else:
		timer.set_wait_time(3)

func basic_attack():
	if current_attack == null:
		return
	if can_attack() == false:
		return
	match current_attack.name:
		"Arrow":
			var arrow_instance = arrow_scene.instance()
			arrow_instance.linear_velocity = current_attack.direction * 800
			arrow_instance.position = to_global(current_attack.position)
			arrow_instance.position.x += current_attack.face_direction * 20
			arrow_instance.position.y -= 10
			arrow_instance.rotation = current_attack.direction.angle()
			arrow_instance.scale.x = current_attack.face_direction
			arrow_instance.add_collision_exception_with(root.get_node("Player"))
			root.add_child(arrow_instance)
		"Fireball":
			var fireball_instance = fireball_scene.instance()
			fireball_instance.linear_velocity = current_attack.direction * 600
			fireball_instance.position = to_global(current_attack.position)
			fireball_instance.position.x += current_attack.face_direction * 20
			fireball_instance.rotation = current_attack.direction.angle()
			fireball_instance.scale.x = current_attack.face_direction
			fireball_instance.add_collision_exception_with(root.get_node("Player"))
			root.add_child(fireball_instance)
		_:
			state_machine.travel(current_attack.name+"_generate"+str_direction)
	
	
func can_attack():
	current_attack.load_data()
	if elements.can_lance(current_attack.element, current_attack.element_consume) == false:
		return false
	else:
		elements.change_value(current_attack.element, current_attack.element_consume)
		element_handler.createElement(current_attack.element, current_attack.element_consume, Vector2(player.position[0] + rand_range(-3, 3), player.position[1]))
		return true
		
func _ready():
	state_machine = get_node("../AnimationTree").get("parameters/playback")
	var count = 0
	#for node in enemies.get_children():
		#connect("launch_attack", node, "_on_Player_weapon_attack")

	state_machine.start("Await")


func _on_Player_character_attack(attack: Action):
	display_attack(attack)

