extends RigidBody2D


func _on_Arrow_body_entered(body):
	if(body.get_name() == "Player"):
		return
	
	queue_free()

func _process(delta):
	rotation = linear_velocity.angle()
	position += linear_velocity * delta
	
func _ready():
	$AnimationPlayer.play("arrow")