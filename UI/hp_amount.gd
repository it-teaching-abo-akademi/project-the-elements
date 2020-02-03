extends TextureProgress

var maximum_value = 100
var current_health = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Indicators_hp_changed(health):
	animate_value(current_health, health)
	current_health = health
	self.value = health
	get_node("Label").text = "%s / %s" % [health, maximum_value]

func _on_Indicators_max_hp_changed(health):
	self.max_value = health
	self.value = health
	maximum_value = health
	get_node("Label").text = "%s / %s" % [maximum_value, maximum_value]

func animate_value(start, end):
	get_node("Tween").interpolate_property(self, "value", start, end, 0.6, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	get_node("Tween").start()