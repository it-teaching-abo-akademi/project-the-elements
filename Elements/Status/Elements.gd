extends Node2D

# 0:Spring 1:Knife 2:Fire 3:Wood 4:Earth
var SPRING = {}
var KNIFE = {}
var FIRE = {}
var WOOD = {}
var EARTH = {}


signal set_max_value(type,value)
signal change_max_value(type,value)
signal change_value(type,value)


func _process(delta):
	change_value(0,-SPRING.recovery_speed * 0.01)
	change_value(1,-KNIFE.recovery_speed * 0.01)
	change_value(2,-FIRE.recovery_speed * 0.01)
	change_value(3,-WOOD.recovery_speed * 0.01)
	change_value(4,-EARTH.recovery_speed * 0.01)

# Called when the node enters the scene tree for the first time.
func _ready():
	#todo read values from global
	init()
	var indicator = get_tree().get_current_scene().get_node("CanvasLayer/Indicators")
	connect("set_max_value",indicator,"_on_Elements_set_max_value")
	connect("change_max_value",indicator,"_on_Elements_change_max_value")
	connect("change_value",indicator,"_on_Elements_change_value")
	emit_signal("set_max_value",0,SPRING.max_amount)
	emit_signal("set_max_value",1,KNIFE.max_amount)
	emit_signal("set_max_value",2,FIRE.max_amount)
	emit_signal("set_max_value",3,WOOD.max_amount)
	emit_signal("set_max_value",4,EARTH.max_amount)
	emit_signal("change_value",0,SPRING.current_amount)
	emit_signal("change_value",1,KNIFE.current_amount)
	emit_signal("change_value",2,FIRE.current_amount)
	emit_signal("change_value",3,WOOD.current_amount)
	emit_signal("change_value",4,EARTH.current_amount)

func init():
	SPRING = global.SPRING
	KNIFE = global.KNIFE
	FIRE = global.FIRE
	WOOD = global.WOOD
	EARTH = global.EARTH
	
func update():
	global.SPRING = SPRING
	global.KNIFE = KNIFE
	global.FIRE = FIRE
	global.WOOD = WOOD
	global.EARTH = EARTH
	
func level_up():
	#todo level up function
	pass
	
func change_max_value(type,v):
	match type:
		0:
			SPRING.max_amount = max(SPRING.max_amount, v)
			emit_signal("change_max_value",0,v)
		1:
			KNIFE.max_amount = max(KNIFE.max_amount, v)
			emit_signal("change_max_value",1,v)
		2:
			FIRE.max_amount = max(FIRE.max_amount, v)
			emit_signal("change_max_value",2,v)
		3:
			WOOD.max_amount = max(WOOD.max_amount, v)
			emit_signal("change_max_value",3,v)
		4:
			EARTH.max_amount = max(EARTH.max_amount, v)
			emit_signal("change_max_value",4,v)
		

func can_lance(type, amount):
	match type:
		0:
			if(SPRING.current_amount<amount):
				return false
			else:
				return true
		1:
			if(KNIFE.current_amount<amount):
				return false
			else:
				return true
		2:
			if(FIRE.current_amount<amount):
				return false
			else:
				return true
		3:
			if(WOOD.current_amount<amount):
				return false
			else:
				return true
		4:
			if(EARTH.current_amount<amount):
				return false
			else:
				return true
				
func get_level(type):
	match type:
		0:
			return SPRING.level
		1:
			return KNIFE.level
		2:
			return FIRE.level
		3:
			return WOOD.level
		4:
			return EARTH.level
	
func change_value(type,amount):
	match type:
		0:
			if(SPRING.current_amount<amount):
				return false
			else:
				SPRING.current_amount -= amount
				if SPRING.current_amount > SPRING.max_amount:
					SPRING.level += 1
					SPRING.max_amount = 100 + SPRING.level * 15
					SPRING.current_amount = SPRING.max_amount / 2
				emit_signal("change_value",0,SPRING.current_amount)
				emit_signal("change_max_value",0,SPRING.max_amount)
				return true
		1:
			if(KNIFE.current_amount<amount):
				return false
			else:
				KNIFE.current_amount -= amount
				if KNIFE.current_amount > KNIFE.max_amount:
					KNIFE.level += 1
					KNIFE.max_amount = 100 + KNIFE.level * 15
					KNIFE.current_amount = KNIFE.max_amount / 2
				emit_signal("change_value",1,KNIFE.current_amount)
				emit_signal("change_max_value",1,KNIFE.max_amount)
				return true
		2:
			if(FIRE.current_amount<amount):
				return false
			else:
				FIRE.current_amount -= amount
				if FIRE.current_amount > FIRE.max_amount:
					FIRE.level += 1
					FIRE.max_amount = 100 + FIRE.level * 15
					FIRE.current_amount = FIRE.max_amount / 2
				emit_signal("change_value",2,FIRE.current_amount)
				emit_signal("change_max_value",2,FIRE.max_amount)
				return true
		3:
			if(WOOD.current_amount<amount):
				return false
			else:
				WOOD.current_amount -= amount
				if WOOD.current_amount > WOOD.max_amount:
					WOOD.level += 1
					WOOD.max_amount = 100 + WOOD.level * 15
					WOOD.current_amount = WOOD.max_amount / 2
				emit_signal("change_value",3,WOOD.current_amount)
				emit_signal("change_max_value",3,WOOD.max_amount)
				return true
		4:
			if(EARTH.current_amount<amount):
				return false
			else:
				EARTH.current_amount -= amount
				if EARTH.current_amount > EARTH.max_amount:
					EARTH.level += 1
					EARTH.max_amount = 100 + EARTH.level * 15
					EARTH.current_amount = EARTH.max_amount / 2
				emit_signal("change_value",4,EARTH.current_amount)
				emit_signal("change_max_value",4,EARTH.max_amount)
				return true