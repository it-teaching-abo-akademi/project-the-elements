extends RigidBody2D


func _on_Arrow_body_entered(body):
	if(body.get_name() == "Player"):
		return
	
	queue_free()

func _process(delta):
	rotation = atan2(linear_velocity.y, linear_velocity.x)