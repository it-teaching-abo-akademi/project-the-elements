extends Control

#constants
const ACTIONS = global.ACTIONS
const CONFIG_FILE = global.CONFIG_FILE


var button #register the pressed button
var action #register the action being handled

			
			
func save_to_config(section, key, value):
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err:
		print("Error loading config file: ", err)
	else:
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


func _on_Back_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")
