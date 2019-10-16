extends Node
"""
this class is used to manage dialogues
"""
class_name DialogueManager

signal started
signal finished

var character_name : String = ""
var text : String = ""
var expression : String

var _conversation : Array
var _index : int = 0

func start(dialogue_dict, index :int = 0):
	"""
	Starts to load the dialogues
	"""
	emit_signal("started")
	_conversation = dialogue_dict.values()
	_index = index
	_update()
	
	
func next():
	"""
	Jumps to next line of the dialogues
	"""
	_index += 1
	assert _index <= _conversation.size()
	_update()
	
	
func _update():
	"""
	Loads the text of the current line
	"""
	character_name = _conversation[_index].name
	text = _conversation[_index].text
	expression = _conversation[_index].expression
	if _index == _conversation.size()-1:
		emit_signal("finished")

func has_text() -> bool:
	"""
	Checks if it has reaches the end of the dialogue
	"""
	return _index < _conversation.size()-1