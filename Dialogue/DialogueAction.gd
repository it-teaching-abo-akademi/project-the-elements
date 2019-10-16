extends Node
"""
this class is used to show the dialogue 
"""
class_name DialogueAction

export (String, FILE, "*.json") var dialogue_file_path : String
signal dialogue_loaded(data)
signal dialogue_finished

onready var dialogue_box : DialogueBox = $DialogueBox

func start(index :int = 0):
	"""
	Starts the dialogue box, you can indicate start from which line, default is from 0
	"""
	var dialogue : Dictionary =  load_dialogue(dialogue_file_path)
	dialogue_box.start(dialogue, index)
	yield(dialogue_box, "dialogue_ended")
	emit_signal("dialogue_finished")
	

func load_dialogue(file_path) -> Dictionary:
	"""
	Parses a JSON file and returns it as a dictionary
	"""
	var file = File.new()
	assert file.file_exists(file_path)

	file.open(file_path, file.READ)
	var dialogue = parse_json(file.get_as_text())
	assert dialogue.size() > 0
	emit_signal("dialogue_loaded")
	return dialogue
