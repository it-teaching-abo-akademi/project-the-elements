extends RigidBody2D



func _on_Fireball_body_entered(body):
	#if "Player" in body.name:
		#return
		
	$ExplodeEffect.emitting = true
	queue_free()
	
func _ready():
	$AnimationPlayer.play("fireball")
	
func _process(delta):
	rotation = linear_velocity.angle()
	position += linear_velocity * delta