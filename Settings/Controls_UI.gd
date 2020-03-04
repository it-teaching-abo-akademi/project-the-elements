extends Control

#constants
var ACTIONS = global.ACTIONS
var CONFIG_FILE = global.CONFIG_FILE


var button #register the pressed button
var action #register the action being handled
var config
			
			
func save_to_config(section, key, value):
	config.set_value(section, key, value)
	config.save(CONFIG_FILE)
		
		
func wait_for_input(action_bind):
	action = action_bind
	button = get_node("bindings").get_node(action).get_node("Button")
	get_node("contextual_help").text = "Press a key to assign to the '"+ action + "' action."
	set_process_input(true)
	
	
func _input(event):
	if event is InputEventKey:
		#register the event as handled and stop it from spreading
		get_tree().set_input_as_handled()
		set_process_input(false)
		#reinitialize the contextual help 
		get_node("contextual_help").text = "Click a key binding to reassign it."
		if not event.is_action("ui_cancel"):
			#display the string corresponding to the pressed key
			var scancode = OS.get_scancode_string(event.scancode)
			button.text = scancode
			#remove the previous key binding
			for old_event in InputMap.get_action_list(action):
				InputMap.action_erase_event(action, old_event)
				check_duplicate(scancode, old_event)
			InputMap.action_add_event(action, event)
			save_to_config("key_settings", action, scancode)


func _ready():
	global.load_config()
	for action in ACTIONS:
		var input_event = InputMap.get_action_list(action)[0]
		var button = get_node("bindings").get_node(action).get_node("Button")
		button.text = OS.get_scancode_string(input_event.scancode)
		button.connect("pressed", self, "wait_for_input", [action])
	#stop processing input until a button is pressed
	set_process_input(false)
	config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err:
		print("Error loading config file: ", err)

func _on_Back_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")

func check_duplicate(new_scancode, old_event):
	for action_name in config.get_section_keys("key_settings"):
			#get the key scancode corresponding to the saved string
			var scancode = OS.find_scancode_from_string(config.get_value("key_settings" , action_name))
			var scancode_str = OS.get_scancode_string(scancode)
			print(scancode_str, " ", new_scancode)
			if scancode_str == new_scancode:
				for event in InputMap.get_action_list(action_name):
					if event is InputEventKey:
						InputMap.action_erase_event(action_name, event)
				InputMap.action_add_event(action_name, old_event)
				save_to_config("key_settings", action_name, OS.get_scancode_string(old_event.scancode))
				get_node("bindings").get_node(action_name).get_node("Button").text = OS.get_scancode_string(old_event.scancode)