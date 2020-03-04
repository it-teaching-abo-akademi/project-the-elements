extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StoryMode_pressed():
	pass # Replace with function body.


func _on_ArenaMode_pressed():
	global.max_hp = 200
	global.current_hp = 200
	global.SPRING = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":10}
	global.KNIFE = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":2}
	global.FIRE = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":2}
	global.WOOD = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":2}
	global.EARTH = {"max_amount":100, "current_amount":100,"level":1,"recovery_speed":2}
	get_tree().change_scene("res://Scenes/Scene1.tscn")
	pass # Replace with function body.


func _on_Settings_pressed():
	get_tree().change_scene("res://Settings/Controls_UI.tscn")
	pass # Replace with function body.


func _on_Exit_pressed():
	get_tree().quit()
	pass # Replace with function body.
