extends Node

#environment variables
const CONFIG_FILE = "res://settings/input.cfg"
const ACTIONS = [ "move_left", "move_right", "change_element_left_previous", "change_element_left_next", "change_element_right_previous", "change_element_right_next", "ctrl", "space" ]



#game data
const UP = Vector2(0, -1) 
const GRAVITY = 9
const FRICTION = 0.02


var max_hp = 200
var current_hp = 200

enum ENEMY_STATES {SLEEP, PATROL, CHASE, ATTACK, DEAD, KNOCK, LIFT,IDLE} # states of enemies
enum DIRECTION {
	DIR_N,
	DIR_S,
	DIR_W,
	DIR_E,
	DIR_NE,
	DIR_NW,
	DIR_SE,
	DIR_SW
}

#Elements
var SPRING = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var KNIFE = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var FIRE = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var WOOD = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
var EARTH = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}


var current_scene = null

var Fire_enemy = preload("res://.import/Fire_origin.png-9c301150443c9d211ed53d15b28488f4.stex")
var Spring_enemy = preload("res://.import/Spring_origin.png-8a8dc2c87d1c481d1f1d3af4f8df01af.stex")
var Knife_enemy = preload("res://.import/Knife_origin.png-c02330c853ea7d1e313d729a4707f709.stex")
var Wood_enemy = preload("res://.import/Wood_origin.png-11ae17ea190a908ddfff32ddbf42927c.stex")
var Earth_enemy = preload("res://.import/Earth_origin.png-3fd7ce9c915b05cf45e15753e1d7b12a.stex")

var fireball_scene = preload("res://Elements/Fireball.tscn")
var arrow_scene = preload("res://Elements/Arrow.tscn")

#functions
func _ready():
	var screen_size = OS.get_screen_size(OS.get_current_screen())
	var window_size = OS.get_window_size()
	var centered_pos = (screen_size - window_size) / 2
	OS.set_window_position(centered_pos)
	load_config()
	global.current_scene = get_tree().get_current_scene()


func load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err: #if the config file is missing, generate default config
		for action_name in ACTIONS:
			var action_list = InputMap.get_action_list(action_name)
			var scancode = OS.get_scancode_string(action_list[0].scancode)
			config.set_value("key_settings", action_name, scancode)
		config.save(CONFIG_FILE)
	else: #config file is successfully loaded
		for action_name in config.get_section_keys("key_settings"):
			#get the key scancode corresponding to the saved string
			var scancode = OS.find_scancode_from_string(config.get_value("key_settings" , action_name))
			#create a new event based on saved scancode
			var event = InputEventKey.new()
			event.scancode = scancode
			#replace old action key by the new one
			for old_event in InputMap.get_action_list(action_name):
				if old_event is InputEventKey:
					InputMap.action_erase_event(action_name, old_event)
			InputMap.action_add_event(action_name, event)