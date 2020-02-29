extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var element_amount
var element_type
var element_is_collectable
var cloud_transform_timer = 0

func _process(delta):
	var velocity = Vector2(rand_range(0,20),0)
	move_and_slide(velocity, global.UP)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
