extends RigidBody2D



func _on_Fireball_body_entered(body):
	if(body.get_name() == "Player"):
		return
		
	$ExplodeEffect.emitting = true
	queue_free()
	
