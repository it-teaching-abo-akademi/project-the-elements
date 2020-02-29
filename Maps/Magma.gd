extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal magma
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if(body.name == "Player"):
		global.current_scene.get_tree().get_current_scene().get_node("Player").magma()


