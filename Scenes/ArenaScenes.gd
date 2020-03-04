extends Node2D

# 0:Spring 1:Knife 2:Fire 3:Wood 4:Earth

func _ready():
	# $Enemies/Monster.add_collision_exception_with($Enemies/Monster2)
	
	global.current_scene = get_tree().get_current_scene()
	var enemies = get_node("Enemies").get_children()
	for e in enemies:
		match self.name:
			'Stage Spring':
				e.get_node("Sprite").set_texture(global.Spring_enemy)
				e.element = 0
			'Stage Knife':
				e.get_node("Sprite").set_texture(global.Knife_enemy)
				e.element = 1
			'Stage Fire':
				e.get_node("Sprite").set_texture(global.Fire_enemy)
				e.element = 2
			'Stage Wood':
				e.get_node("Sprite").set_texture(global.Wood_enemy)
				e.element = 3
			'Stage Earth':
				e.get_node("Sprite").set_texture(global.Earth_enemy)
				e.element = 4
	
		if(e.name.begins_with('Arrow')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Arrow"
			e.attack_mode.load_data()
			e.get_node('RayCast2D2').cast_to.y = 90
			e.set_status(2250,3,70)
			
		elif(e.name.begins_with('Fireball')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Fireball"
			e.attack_mode.load_data()
			e.get_node('RayCast2D2').cast_to.y = 90
			e.set_status(1750,3,80)
			
		elif(e.name.begins_with('Lift')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Lift"
			e.attack_mode.load_data()
			e.get_node('RayCast2D2').cast_to.y = 45
			e.set_status(5500,2,200)
			
		elif(e.name.begins_with('Slash')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Slash"
			e.attack_mode.load_data()
			e.get_node('RayCast2D2').cast_to.y = 25
			e.set_status(6500,3,100)
			
		elif(e.name.begins_with('Thrust')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Thrust"
			e.attack_mode.load_data()
			e.get_node('RayCast2D2').cast_to.y = 45
			e.set_status(4000,4,150)