extends Node

#environment variables
const CONFIG_FILE = "user://input.cfg"
const ACTIONS = [ "move_left", "move_right", "up", "down" ]


#game data
const UP = Vector2(0, -1) 
const GRAVITY = 10
const CHARACTER_SPEED = 150 #character moving speed
const JUMP_HEIGHT = -500  #character jumping height
const FLYING_SPEED = 20  #character flying speed 
const FLYING_ADJUST_SPEED = 20  #character adjusting speed while flying
const BURST_SPEED = 50  #character burst speed
const FUEL_CONSUME = 1  #character fuel consume per time unit
const BURST_FUEL_CONSUME = 20  #character burst fuel consuming per time unit

enum CHARACTER_STATES {STATE_IDLE, STATE_ATTACK, STATE_FLY}  # states of charater


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