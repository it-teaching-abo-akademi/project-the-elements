extends RigidBody2D

var arrow : Action = null

func _on_Arrow_body_entered(body):
	if arrow == null:
		arrow = Action.new()
		arrow.name = "Fireball"
		arrow.load_data()
	if linear_velocity.x > 0:
		arrow.face_direction = -1
	else:
		arrow.face_direction = 1
	if "Player" in body.name:
		body._on_EnemyModel_attack(arrow)
	if "Enemy" in body.name:
		body._on_Player_weapon_attack(arrow)
	
	queue_free()

func _process(delta):
	rotation = linear_velocity.angle()
	position += linear_velocity * delta
	
func _ready():
	$AnimationPlayer.play("arrow")