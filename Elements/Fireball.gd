extends RigidBody2D

var fireball : Action = null

func _on_Fireball_body_entered(body):
	if fireball == null:
		fireball = Action.new()
		fireball.name = "Fireball"
		fireball.load_data()
	if linear_velocity.x > 0:
		fireball.face_direction = -1
	else:
		fireball.face_direction = 1
	if "Player" in body.name:
		body._on_EnemyModel_attack(fireball)
	if "Enemy" in body.name:
		body._on_Player_weapon_attack(fireball)
	$ExplodeEffect.emitting = true
	queue_free()
	
func _ready():
	$AnimationPlayer.play("fireball")
	
func _process(delta):
	rotation = linear_velocity.angle()
	position += linear_velocity * delta