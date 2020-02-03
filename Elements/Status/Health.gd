extends Node2D


export(int) var MAX_HP = 100
export(int) var CURRENT_HP = 100
export(bool) var IS_DEAD = false

signal set_max_hp(health)
signal on_hp_changed(health)

# Called when the node enters the scene tree for the first time.
func _ready():
	CURRENT_HP = MAX_HP
	emit_signal("set_max_hp",MAX_HP)

func _get_hit(damage):
	CURRENT_HP-= damage
	CURRENT_HP = max(0, CURRENT_HP)
	IS_DEAD = true
	emit_signal("on_hp_changed",CURRENT_HP)

func _is_dead():
	if(IS_DEAD):
		IS_DEAD = false
		CURRENT_HP = MAX_HP
		get_tree().change_scene("res://Scenes/MainStage.tscn")	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(CURRENT_HP == 0):
		IS_DEAD = true
		_is_dead()
#	pass
