extends Area2D

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		var attack = get_owner().get("attack_mode")
		body._on_EnemyModel_attack(attack)