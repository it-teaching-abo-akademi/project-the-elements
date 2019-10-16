extends Node

class_name DialogueDatabase

const SOURCE_DIRECTORY = "res://Dialogue/Character"
var characters : Dictionary


func _ready():
	"""
	Fetchs information of the characters
	"""
	var dir = Directory.new()
	assert dir.dir_exists(SOURCE_DIRECTORY)
	if not dir.open(SOURCE_DIRECTORY) == OK:
		print("Can't read directory %" % SOURCE_DIRECTORY)
	dir.list_dir_begin()
	var file_name : String
	while true:
		file_name = dir.get_next()
		if file_name == "":
			break
		if not file_name.ends_with(".tres"):
			continue
		characters[file_name.get_basename()] = load(SOURCE_DIRECTORY.plus_file(file_name))
		

func get_texture(character_name : String, expression : String = "neutral") -> Texture:
	"""
	Fetchs the texture of the characters
	"""
	assert character_name in characters
	assert expression in characters[character_name].expressions
	return characters[character_name].expressions[expression]