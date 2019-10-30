extends Node

#environment variables
const CONFIG_FILE = "res://settings/input.cfg"
const ACTIONS = [ "move_left", "move_right", "change_element_left_previous", "change_element_left_next", "change_element_right_previous", "change_element_right_next", "ctrl", "space" ]
const ELEMENTS = [ "Spring", "Knife", "Fire", "Wood", "Earth"]


#game data
const UP = Vector2(0, -1) 
const GRAVITY = 500
const CHARACTER_SPEED = 15000 #character moving speed
const JUMP_HEIGHT = -50000  #character jumping height
const FLYING_SPEED = 2000  #character flying speed 
const FLYING_ADJUST_SPEED = 2000 #character adjusting speed while flying
const BURST_SPEED = 5000  #character burst speed
const FUEL_CONSUME = 10  #character fuel consume per time unit
const BURST_FUEL_CONSUME = 20  #character burst fuel consuming per time unit
const FRICTION = 0.1

enum CHARACTER_STATES {STATE_IDLE, STATE_ATTACK, STATE_FLY}  # states of charater
enum ENEMY_STATES {SLEEP, PATROL, CHASE, ATTACK, DEAD, KNOCK, LIFT} # states of enemies
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

#Enemies data
var speed = 5
var strength = 5
var hp = 100
var max_hp = 100
var detection_range = 200
var attack_range = 10
var preferred_attack_range = 10
var busy = false # If the enemy can do next move or not





#functions
func _ready():
	var screen_size = OS.get_screen_size(OS.get_current_screen())
	var window_size = OS.get_window_size()
	var centered_pos = (screen_size - window_size) / 2
	OS.set_window_position(centered_pos)
	load_config()


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