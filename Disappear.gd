extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func disappear():
	queue_free()
	$StaticBody2D/CollisionShape2D.disabled = true



func _on_Area2D_body_entered(body):
	if(body.name == "Player"):
		disappear()
