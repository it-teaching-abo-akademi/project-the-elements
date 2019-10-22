extends Node2D

func _on_Player_character_attack(attack:Attack):
	# The player attacked. We need to check here if the current monster is hurt
	# TODO: the check is just for debug, it needs to be improved
	if position.x < attack.start_position.x + attack.range_effect:
		print("Damage done: " + str(attack.damage))
