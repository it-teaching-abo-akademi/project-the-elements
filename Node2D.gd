extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var v1 = Vector2(1,0)
	var v2 = Vector2(1,1)
	print(v2.angle_to_point(v1))
