extends Node2D

# ElementHandler creates instances of the Element Scene
# and handles their behavior when the player gets close enough.

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Collection and attraction range
var attractionRange = 80
var collectionRange = 40

# Reference to the element scene
var elementScene

# Reference to hero
var hero

# List of element instances, changes dynamically
var elements = []
var elements_to_remove = []

# Scene gravity, can be set with set_gravity()
var gravity

enum {WATER, KNIFE, FIRE, WOOD, SOIL}

const _ELEMENT_COLORS = [
	Color(0, 0.5, 1), # Water
	Color(0.5, 0.5, 0.5), # Knife
	Color(1, 0, 0), # Fire
	Color(0.1, 0.8, 0), # Wood
	Color(0.5, 0.4, 0), # Soil
]

# Called when the node enters the scene tree for the first time.
func _ready():
	elementScene = preload("res://Elements-collectable/ElementScene.tscn")
	hero = get_node("/root/"+get_tree().get_current_scene().get_name()+"/Player")

func refPlayer(p):
	hero = p

func set_gravity(g):
	gravity = Vector2(0, g)

# list of timers (each element needs its own timer)
var cloud_timers = []

func _turn_into_cloud():
	# Turn particles into cloud point
	var elem = elements[-1]
	var particles = elem.get_node("ElementParticles")
	particles.process_material.scale = 2
	# particles.amount = 120
	particles.process_material.initial_velocity = 15
	particles.process_material.trail_divisor = 4
	particles.explosiveness = 0.2
	elem.element_is_collectable = true
	cloud_timers.remove(0)
	

## type = 0 to 4, amount = 0.1 to 1.0, position = Vector2(x, y)
func createElement(type, amount, position):
	cloud_timers.append(Timer.new())
	cloud_timers[-1].set_one_shot(true)
	cloud_timers[-1].set_timer_process_mode(Timer.TIMER_PROCESS_IDLE)
	cloud_timers[-1].set_wait_time(1.0)
	cloud_timers[-1].connect("timeout", self, "_turn_into_cloud")
	add_child(cloud_timers[-1])
	cloud_timers[-1].start()
	# Make an instance of the element scene
	var element = elementScene.instance()
	var particles = element.get_node("ElementParticles")
	# Make the process material and its objects unique for this instance (making it independent of other instances)
	particles.process_material = particles.process_material.duplicate()
	particles.process_material.color_ramp = particles.process_material.color_ramp.duplicate()
	particles.process_material.color_ramp.gradient = particles.process_material.color_ramp.gradient.duplicate()
	element.position = position
	# The amount of the element brightens the color
	particles.process_material.color_ramp.gradient.set_color(0, _ELEMENT_COLORS[type].lightened(amount*0.5))
	# Set the type and amount in the instance
	element.element_type = type
	element.element_amount = amount
	# The element is collectable, when it turns into its cloud form
	element.element_is_collectable = false
	
	# Do not collide physically with the player, or other elements
	element.add_collision_exception_with(hero)
	for elem in elements:
		element.add_collision_exception_with(elem)
	
	#element.Node
	add_child(element)
	
	elements.append(element)


func _element_process(element, delta):
	# Gravity
	element.move_and_collide(gravity * delta)
	
	_element_collection_process(element, delta)

# List of timers
var collection_timers = []

func _remove_element():
	# Remove the instance and the references to it
	print(elements_to_remove[0])
	elements_to_remove[0].queue_free()
	elements.erase(elements_to_remove[0])
	elements_to_remove.remove(0)
	collection_timers.remove(0)

# Handles Element collection behavior
func _element_collection_process(element, delta):
	var particles = element.get_node("ElementParticles")
	# The element collection is done only when the element is in cloud form
	if !element.element_is_collectable:
		return
	# Check distance to player
	var dx = element.position[0] - hero.position[0]
	var dy = element.position[1] - hero.position[1]
	# print(dx,dy)
	# If within attraction range, the element moves towards player
	if (-attractionRange <= dx && dx <= attractionRange
		&& -attractionRange <= dy && dy <= attractionRange):
		
		# Set gravity towards player (for absorbing effect)
		particles.process_material.set_gravity(Vector3(-dx, dy, 0)*2)
		particles.process_material.orbit_velocity = 0
		# Move towards player
		element.position = Vector2(element.position[0] - dx*delta, element.position[1] - dy*delta)
		# If element reaches the player, it is collected
		if (-collectionRange <= dx && dx <= collectionRange
			&& -collectionRange <= dy && dy <= collectionRange):
			
				# If the element has been collected, some things should not occur, like recollecting
			if !element in elements_to_remove:
				hero.element_collected(element.element_type, element.element_amount)
				# Animate collection
				particles.process_material.scale = 1
				particles.process_material.initial_velocity = 30
				particles.process_material.trail_divisor = 1
				particles.explosiveness = 0.2
			
				# Remove element after the animation has played
				elements_to_remove.append(element)
				collection_timers.append(Timer.new())
				collection_timers[-1].set_one_shot(true)
				collection_timers[-1].set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
				collection_timers[-1].set_wait_time(1.0)
				collection_timers[-1].connect("timeout", self, "_remove_element")
				add_child(collection_timers[-1])
				collection_timers[-1].start()
			
	else:
		particles.process_material.set_gravity(Vector3(0, 0, 0))
	
	# Handle lifetime
	# TODO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Do the processing in each element instance
	for elem in elements:
		_element_process(elem, delta)

