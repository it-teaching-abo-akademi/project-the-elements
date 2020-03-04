extends Object

class_name Action

const statistics_class = preload("res://Attack/ActionStatistics.gd")
var statistics = statistics_class.new()

var element_select:int = -1 setget set_element_select, get_element_select
var face_direction:int = 1 setget set_face_direction, get_face_direction

var name = null
var element = null
var damage = 0
var range_effect = 0
var time_before = 0
var time_action = 0
var time_after = 0
var knock_power = 0
var element_consume = 10
var boost_factor = 1.5
var direction = Vector2.ZERO
var display_size_factor = 1.0
var position = Vector2.ZERO

# TODO: element consumed

# It can be an idea to have an 'Effect' class, who handle the effect
# For example, the enemy call methods from this class to create the effect
# without having to check every case itself
# Same for combo effects

# The effect the attack can have (e.g Lift/Knock)
# Should be loaded from somewhere

var effect:int = 0

var is_combo:bool = false setget set_is_combo, is_combo
var combo_effect:int = 0 setget set_combo_effect, get_combo_effect

var points = []

func init_again():
	# TODO: init again everything
	pass

func set_is_combo(ic:bool):
	is_combo = ic

func is_combo():
	return is_combo

func set_combo_effect(cb:int):
	combo_effect = cb

func get_combo_effect():
	return combo_effect

func set_element_select(e:int):
	element_select = e

func get_element_select():
	return element_select

func set_face_direction(dir:int):
	face_direction = dir

func get_face_direction():
	return face_direction

func load_data():
	if name == null:
		return
	var data = statistics.get(name)
	if data == null:
		return
	if data.has("damage"):
		damage = data["damage"]
	if data.has("range_effect"):
		range_effect = data["range_effect"]
	if data.has("time_before"):
		time_before = data["time_before"]
	if data.has("time_action"):
		time_action = data["time_action"]
	if data.has("time_after"):
		time_after = data["time_after"]
	if data.has("knock_power"):
		knock_power = data["knock_power"]
	if data.has("element_consume"):
		element_consume = data["element_consume"]
	if data.has("boost_factor"):
		boost_factor = data["boost_factor"]
	
	