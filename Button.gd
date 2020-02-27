extends Node2D


onready var timer = get_node("Timer")
onready var left = get_node("Sprite2")
onready var right = get_node("Sprite3")
onready var fireball_scene = preload("res://Elements/Fireball.tscn")
onready var root = get_tree().get_current_scene()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.set_wait_time(3)
	pass



func _on_Area2D_body_entered(body):
	get_node("Sprite").queue_free()
	$Sprite/Area2D/CollisionShape2D.disabled = true
	timer.start()
	

func _on_Timer_timeout():
	var fireball_instance = fireball_scene.instance()
	fireball_instance.linear_velocity = Vector2(1,0) * 600
	fireball_instance.position = to_global(left.position)
	fireball_instance.position.x += 20
	fireball_instance.rotation = Vector2(1,0).angle()
	fireball_instance.scale.x = 1
	root.add_child(fireball_instance)
	var fireball_instance2 = fireball_scene.instance()
	fireball_instance2.linear_velocity = Vector2(-1,0) * 600
	fireball_instance2.position = to_global(right.position)
	fireball_instance2.position.x += -20
	fireball_instance2.rotation = Vector2(-1,0).angle()
	fireball_instance2.scale.x = 1
	root.add_child(fireball_instance2)
