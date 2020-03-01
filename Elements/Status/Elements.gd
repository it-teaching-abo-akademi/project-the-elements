extends Node2D

# 0:Spring 1:Knife 2:Fire 3:Wood 4:Earth
var SPRING = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var KNIFE = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var FIRE = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var WOOD = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var EARTH = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}


signal set_max_value(type,value)
signal change_max_value(type,value)
signal change_value(type,value)

# Called when the node enters the scene tree for the first time.
func _ready():
	#todo read values from global
	var indicator = get_tree().get_current_scene().get_node("CanvasLayer/Indicators")
	connect("set_max_value",indicator,"_on_Elements_set_max_value")
	connect("change_max_value",indicator,"_on_Elements_change_max_value")
	connect("change_value",indicator,"_on_Elements_change_value")
	emit_signal("set_max_value",0,SPRING.max_amount)
	emit_signal("set_max_value",1,KNIFE.max_amount)
	emit_signal("set_max_value",2,FIRE.max_amount)
	emit_signal("set_max_value",3,WOOD.max_amount)
	emit_signal("set_max_value",4,EARTH.max_amount)
	
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
		

func change_value(type,amount):
	match type:
		0:
			if(SPRING.current_amount<amount):
				return false
			else:
				SPRING.current_amount -= amount
				SPRING.current_amount = min(SPRING.current_amount,SPRING.max_amount)
				emit_signal("change_value",0,SPRING.current_amount)
				return true
		1:
			if(KNIFE.current_amount<amount):
				return false
			else:
				KNIFE.current_amount -= amount
				KNIFE.current_amount = min(KNIFE.current_amount,KNIFE.max_amount)
				emit_signal("change_value",1,KNIFE.current_amount)
				return true
		2:
			if(FIRE.current_amount<amount):
				return false
			else:
				FIRE.current_amount -= amount
				FIRE.current_amount = min(FIRE.current_amount,FIRE.max_amount)
				emit_signal("change_value",2,FIRE.current_amount)
				return true
		3:
			if(WOOD.current_amount<amount):
				return false
			else:
				WOOD.current_amount -= amount
				WOOD.current_amount = min(WOOD.current_amount,WOOD.max_amount)
				emit_signal("change_value",3,WOOD.current_amount)
				return true
		4:
			if(EARTH.current_amount<amount):
				return false
			else:
				EARTH.current_amount -= amount
				EARTH.current_amount = min(EARTH.current_amount,EARTH.max_amount)
				emit_signal("change_value",4,EARTH.current_amount)
				return true