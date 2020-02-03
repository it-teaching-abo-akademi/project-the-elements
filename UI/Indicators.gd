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
signal hp_changed(health)
signal max_hp_changed(health)

func _on_Health_on_hp_changed(health):
	emit_signal("hp_changed",health)


func _on_Health_set_max_hp(health):
	emit_signal("max_hp_changed",health)
