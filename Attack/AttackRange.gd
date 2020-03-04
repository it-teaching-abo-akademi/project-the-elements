extends Area2D

var weapon = null

func _on_Area2D_body_entered(body):
	if body.name.begins_with('Slash')||body.name.begins_with('Thrust')||body.name.begins_with('Fireball')||body.name.begins_with('Arrow')||body.name.begins_with('Lift'):
		if weapon == null:
			weapon = global.current_scene.get_node('Player').get_node('AttackSystem').get_node('Weapon')
		body._on_Player_weapon_attack(weapon.get('recent_attack'))