extends Node2D

signal begin_appear
signal end_appear

signal begin_move
signal end_move

signal begin_disappear
signal end_disappear

const WEAPON_KATANA = 0
const WEAPON_SPEAR = 1

var is_weapon_set = false

const KATANA_ROTATION = 90.0

const SPEAR_MOVE_X = 100.0
const SPEAR_START_POSITION = Vector2(100.0, 0.0)

const STATE_HIDED = 0
const STATE_APPEAR = 1
const STATE_VISBLE = 2
const STATE_DISAPPEAR = 3
const STATE_ATTACK = 4

var timer:float = 0.0
var state = STATE_HIDED

var current_weapon = -1

var appear_time = 0.0
var disappear_time = 0.0
var attack_time = 0.0

var emited = false

# 1 -> right ; -1 -> left
var direction = 1 setget set_direction, get_direction

#func _ready():
#	display_attack(WEAPON_SPEAR, -1)

var need_direction_change = false
var direction_requested = 0

var global_vfx = null

func display_attack(attack:Attack, dir:int):
	if is_weapon_set:
		return
	_re_init()
	set_direction(dir)
	set_weapon(attack)
	appear()


func set_direction(new_direction):
	if is_weapon_set:
		# An attack is being processed, we'll change after
		need_direction_change = true
		direction_requested = new_direction
	else:
		need_direction_change = false
		direction = new_direction
		$Sprite.scale.x = new_direction * abs($Sprite.scale.x)

func _re_init():
	is_weapon_set = false
	var sprite = $Sprite
	sprite.position = Vector2(0.0, 0.0)
	sprite.scale.x = abs(sprite.scale.x)
	sprite.rotation = 0.0
	rotation = 0.0
	position = Vector2(0.0, 0.0)
	scale.x = abs(scale.x)
	

func get_direction():
	return direction

func set_weapon(attack:Attack):
	print("set_weapon(" + attack.name + ")")
	if attack.name == "Slash":
		current_weapon = WEAPON_KATANA
	elif attack.name == "Thrust":
		current_weapon = WEAPON_SPEAR
	
	is_weapon_set = true
	
	var sprite = $Sprite
	if current_weapon == WEAPON_KATANA:
		# Display katana
		var katana_image = Image.new()
		katana_image.load("res://Attack/katana.png")
		
		var katana_texture = ImageTexture.new()
		katana_texture.create_from_image(katana_image)
		
		sprite.texture = katana_texture
		sprite.material.set_shader_param("WeaponTexture", katana_texture)
		sprite.material.set_shader_param("dissolve", -1.0)
		
		appear_time = attack.time_before
		disappear_time = attack.time_after
		attack_time = attack.time_attack
		
		sprite.position.y = -1 * 100.0
		$VisualEffect.position.y = -1 * 50.0
		
		var vfx = VFXTrail.new()
		vfx.from = Vector2(direction * -7, -50)
		vfx.to = Vector2(direction * -7, -190)
		vfx.point_count = 20
		vfx.line_width = vfx.Repartition.RANDOM
		vfx.minimum_line_width = 5
		vfx.maximum_line_width = 15
		vfx.line_length = vfx.Repartition.RANDOM
		vfx.minimum_length = 7
		vfx.maximum_length = 12
		vfx.name = "VFX"
		
		add_child(vfx)
		
		global_vfx = vfx
		
	elif current_weapon == WEAPON_SPEAR:
		# Display spear
		var spear_image = Image.new()
		spear_image.load("res://Attack/spear.png")
		
		var spear_texture = ImageTexture.new()
		spear_texture.create_from_image(spear_image)
		
		sprite.texture = spear_texture
		sprite.material.set_shader_param("WeaponTexture", spear_texture)
		sprite.material.set_shader_param("dissolve", -1.0)
		
		appear_time = attack.time_before
		disappear_time = attack.time_after
		attack_time = attack.time_attack
		
		sprite.position = direction * SPEAR_START_POSITION
		$VisualEffect.position.x = direction * SPEAR_START_POSITION.x / 2.0
		
		var vfx = VFXTrail.new()
		vfx.from = Vector2(0, -4)
		vfx.to = Vector2(0, 4)
		vfx.point_count = 5
		vfx.line_width = vfx.Repartition.RANDOM
		vfx.minimum_line_width = 1
		vfx.maximum_line_width = 6
		vfx.line_length = vfx.Repartition.RANDOM
		vfx.minimum_length = 5
		vfx.maximum_length = 10
		vfx.name = "VFX"
		
		add_child(vfx)
		
		global_vfx = vfx
	else:
		# Unknown weapon
		is_weapon_set = false

func _process(delta):
	if not is_weapon_set:
		return
	
	if state == STATE_APPEAR:
		timer += delta
		var sprite = $Sprite
		if timer < appear_time:
			if timer > appear_time / 5.0 and emited == false:
				$VisualEffect.emitting = true
				emited = true
			sprite.material.set_shader_param("dissolve", timer / appear_time - 1.0)
		else:
			sprite.material.set_shader_param("dissolve", 0.0)
			_set_state(STATE_ATTACK)
	elif state == STATE_DISAPPEAR:
		timer += delta
		var sprite = $Sprite
		if timer < disappear_time:
			sprite.material.set_shader_param("dissolve", 0.0 - timer / disappear_time)
		else:
			sprite.material.set_shader_param("dissolve", -1.0)
			_set_state(STATE_HIDED)
	elif state == STATE_ATTACK:
		if current_weapon == WEAPON_KATANA:
			_katana_attack(delta)
		elif current_weapon == WEAPON_SPEAR:
			_spear_attack(delta)

func appear():
	if not is_weapon_set:
		return
	_set_state(STATE_APPEAR)

func disappear():
	if not is_weapon_set:
		return
	_set_state(STATE_DISAPPEAR)

func attack():
	if not is_weapon_set:
		return
	_set_state(STATE_ATTACK)

func _set_state(new_state: int):
	if new_state == STATE_APPEAR:
		emit_signal("begin_appear")
	elif new_state == STATE_DISAPPEAR:
		emit_signal("begin_disappear")
	elif new_state == STATE_HIDED:
		is_weapon_set = false
		if need_direction_change:
			set_direction(direction_requested)
	
	if state == STATE_APPEAR:
		emit_signal("end_appear")
	elif state == STATE_DISAPPEAR:
		emit_signal("end_disappear")
		if global_vfx != null:
			remove_child(global_vfx)
			global_vfx.free()
			global_vfx = null
	
	state = new_state
	timer = 0.0

func _katana_attack(delta: float):
	if timer < attack_time:
		timer += delta
		# curves: https://github.com/godotengine/godot/issues/10572
		rotation_degrees = direction * ease(timer / attack_time, 4) * KATANA_ROTATION
	else:
		rotation_degrees = direction * KATANA_ROTATION
		_set_state(STATE_DISAPPEAR)
	
func _spear_attack(delta: float):
	if timer < attack_time:
		timer += delta
		position.x = direction * ease(timer / attack_time, 4) * SPEAR_MOVE_X
	else:
		position.x = direction * SPEAR_MOVE_X
		_set_state(STATE_DISAPPEAR)



func _on_Player_character_attack(attack:Attack):
	# Display the attack
	print("param test: " + str(attack.get_parameter("test")))
	display_attack(attack, attack.direction)
