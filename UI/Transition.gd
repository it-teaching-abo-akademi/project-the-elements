extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animation_player = $AnimationPlayer
onready var label = $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = get_tree().get_current_scene().name
	label.modulate = Color(1,1,1,0)
	self.modulate = Color(1,1,1,1)
	animation_player.play("ShowText")
	yield(animation_player,"animation_finished")
	animation_player.play("Fade")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
