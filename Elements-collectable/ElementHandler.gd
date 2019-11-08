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
	hero = get_node("/root/MainStage/Player")

## type = 0 to 4, amount = 0.1 to 1.0, position = Vector2(x, y)
func createElement(type, amount, position):
	# Make an instance of the element scene
	var element = elementScene.instance()
	# Make the process material unique for this instance (making it independent of other instances)
	element.process_material = element.process_material.duplicate()
	element.position = position
	# The amount of the element brightens the color
	element.process_material.set_color(_ELEMENT_COLORS[type].lightened(amount*0.5))
	
	# Set the type and amount in the instance
	element.type = type
	element.amount = amount
	
	#element.Node
	add_child(element)
	
	elements.append(element)


# Handles Element behavior
func element_process(element, delta):
	# Check distance to player
	var dx = element.position[0] - hero.position[0]
	var dy = element.position[1] - hero.position[1]
	# print(dx,dy)
	# If within attraction range, the element moves towards player
	if (-attractionRange <= dx && dx <= attractionRange
		&& -attractionRange <= dy && dy <= attractionRange):
		
		# Set gravity against player (leaving a trail)
		element.process_material.set_gravity(Vector3(dx, dy, 0))
		# Move towards player
		element.position = Vector2(element.position[0] - dx*delta, element.position[1] - dy*delta)
		# If element reaches the player, it is collected
		if (-collectionRange <= dx && dx <= collectionRange
			&& -collectionRange <= dy && dy <= collectionRange):
			hero.element_collected(element.type, element.amount)
			# Remove the instance and the reference to it
			elements.erase(element)
			element.queue_free()
	else:
		element.process_material.set_gravity(Vector3(0, 0, 0))
	
	# Handle lifetime
	# TODO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Do the processing in each element instance
	for elem in elements:
		element_process(elem, delta)

