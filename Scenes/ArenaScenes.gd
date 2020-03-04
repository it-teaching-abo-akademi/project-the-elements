extends Node2D

# 0:Spring 1:Knife 2:Fire 3:Wood 4:Earth

func _ready():
	# $Enemies/Monster.add_collision_exception_with($Enemies/Monster2)
	
	global.current_scene = get_tree().get_current_scene()
	var enemies = get_node("Enemies").get_children()
	match self.name:
		'Stage Spring':
			global.level = 0
		'Stage Knife':
			global.level = 1
		'Stage Fire':
			global.level = 2
		'Stage Wood':
			global.level = 3
		'Stage Earth':
			global.level = 4
			
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
				
		if(e.name.begins_with('EArrow')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Arrow"
			e.attack_mode.load_data()
			e.attack_mode.damage *= 0.3
			e.get_node('RayCast2D2').cast_to.y = 90
			e.set_status(2250,3,240 * (1 + global.level * 0.1))
			
		elif(e.name.begins_with('EFireball')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Fireball"
			e.attack_mode.load_data()
			e.attack_mode.damage *= 0.3
			e.get_node('RayCast2D2').cast_to.y = 90
			e.set_status(1750,3,240 * (1 + global.level * 0.1))
			
		elif(e.name.begins_with('ELift')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Lift"
			e.attack_mode.load_data()
			e.attack_mode.damage *= 0.3
			e.get_node('RayCast2D2').cast_to.y = 45
			e.set_status(5500,2,320 * (1 + global.level * 0.1))
			
		elif(e.name.begins_with('ESlash')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Slash"
			e.attack_mode.load_data()
			e.attack_mode.damage *= 0.3
			e.get_node('RayCast2D2').cast_to.y = 25
			e.set_status(6500,3,400 * (1 + global.level * 0.1))
			
		elif(e.name.begins_with('EThrust')):
			e.attack_mode = Action.new()
			e.attack_mode.name = "Thrust"
			e.attack_mode.load_data()
			e.attack_mode.damage *= 0.3
			e.get_node('RayCast2D2').cast_to.y = 45
			e.set_status(4000,4,320 * (1 + global.level * 0.1))