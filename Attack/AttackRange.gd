extends Area2D

var weapon = null

func _on_Area2D_body_entered(body):
	if body.name.begins_with('ESlash')||body.name.begins_with('EThrust')||body.name.begins_with('EFireball')||body.name.begins_with('EArrow')||body.name.begins_with('ELift'):
		if weapon == null:
			weapon = global.current_scene.get_node('Player').get_node('AttackSystem').get_node('Weapon')
		body._on_Player_weapon_attack(weapon.get('recent_attack'))