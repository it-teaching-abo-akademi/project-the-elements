extends Node2D

const STATE_HIDED = 0
const STATE_APPEAR = 1
const STATE_VISBLE = 2
const STATE_DISAPPEAR = 3
const STATE_ATTACK = 4

var state = STATE_HIDED

var first_attack = null
var second_attack = null

var current_attack = null

var appear_time = 0.0
var disappear_time = 0.0
var attack_time = 0.0

var timer = null
# 1 -> right ; -1 -> left
var direction = 1

var state_machine

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
	match first_attack:
		null:
			#是什么技能就用什么技能
			print(current_attack.name)
			record_attack(current_attack)
		"Lift":
			match current_attack.name:
				"Arrow":
					print("Arrow power up")
					clear_record()
				"Slash":
					print("Heavy slash")
					clear_record()
				"Lift":
					print("180 lift")
					clear_record()
				_:
					#不为连招，重新记录
					print(current_attack.name)
					clear_record()
					record_attack(current_attack)
		"Thrust":
			match second_attack:
				null:
					match current_attack.name:
						"Lift":
							print("Fast lift")
							clear_record()
						"Slash":
							print("Heavy slash")
							clear_record()
						"Thrust":
							print("Thrust")
							record_attack(current_attack)
						_:
							#不为连招，重新记录
							print(current_attack.name)
							clear_record()
							record_attack(current_attack)
				"Thrust":
					match current_attack.name:
						"Thrust":
							print("Lunge")
							clear_record()
						"Slash":
							print("Sword wave")
							clear_record()
						_:
							#不为连招，重新记录
							print(current_attack.name)
							clear_record()
							record_attack(current_attack)
		"Slash":
			match current_attack.name:
				"Thrust":
					print("Laijutsu")
					clear_record()
				"Lift":
					print("Higher lift")
					clear_record()
				_:
					#不为连招，重新记录
					print(current_attack.name)
					clear_record()
					record_attack(current_attack)
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
		timer.set_wait_time(5)
		timer.set_one_shot(true)
		self.add_child(timer)
		timer.start()
		yield(timer, "timeout")
		timer.queue_free()
		timer = null
		clear_record()
	else:
		timer.set_wait_time(5)
	
	
func _ready():
	state_machine = get_node("../AnimationTree").get("parameters/playback")

func _on_Player_character_attack(attack: Action):
	display_attack(attack)
