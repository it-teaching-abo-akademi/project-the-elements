extends Control
class_name DialogueBox

signal dialogue_ended()

onready var dialogue_manager : DialogueManager =$DialogueManager
onready var dialogue_database : DialogueDatabase =$DialogueDatabase

onready var name_label : = $Panel/Columns/Name as Label
onready var text_label : = $Panel/Columns/Text as Label

onready var portrait : = $Portrait as TextureRect

var _conversation : Array

func start(dialogue : Dictionary, index :int = 0):
	"""
	Initialize the UI
	"""
	
	set_process_input(true)
	_conversation = dialogue.values()
	dialogue_manager.start(dialogue, index)
	update_content()
	show()

func _input(event):
	"""
	Detects mouse clicks then show the next line of the text or skip
	"""
	if event is InputEventMouseButton and event.is_pressed():
		if text_label.get_visible_characters() > text_label.get_total_character_count():
			if dialogue_manager.has_text():
				dialogue_manager.next()
				update_content()
			else:
				emit_signal("dialogue_ended")
				hide()
		else:
			text_label.set_visible_characters(text_label.get_total_character_count())

func _on_Timer_timeout():
	"""
	Controls the speed of appearance of the text
	"""
	text_label.set_visible_characters(text_label.get_visible_characters()+1)

func update_content():
	"""
	Updates the content of the label and texture
	"""
	var dialogue_manager_name = dialogue_manager.character_name
	name_label.text = dialogue_manager_name
	text_label.set_text(dialogue_manager.text)
	text_label.set_visible_characters(0)
	portrait.texture = dialogue_database.get_texture(dialogue_manager_name, dialogue_manager.expression)
	portrait.expand = true

func _on_ButtonSkip_pressed():
	emit_signal("dialogue_ended")
	hide()
