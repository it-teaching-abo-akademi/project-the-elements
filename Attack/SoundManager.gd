extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var delay_time = 0.15
#Times should be replaced with 
func _on_Weapon_slash(time):
	print(time)
	var t = Timer.new()
	t.set_wait_time(time + delay_time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	get_node("Slash").play()
	t.queue_free()


func _on_Weapon_thrust(time):
	print(time)
	var t = Timer.new()
	t.set_wait_time(time + delay_time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	get_node("Thrust").play()
	t.queue_free()
	


func _on_Player_spring_burst():
	get_node("Spring").play()
