extends TextureProgress

var maximum_value = 100
var current_value = 0


func change_value(v): 
	animate_value(current_value, v)
	current_value = v
	self.value = v
	if(get_node("Label")!=null):
		get_node("Label").text = "%s / %s" % [v, maximum_value]

func set_max_value(v): #current_value = max_value
	self.max_value = v
	self.value = v
	maximum_value = v
	if(get_node("Label")!=null):
		get_node("Label").text = "%s / %s" % [maximum_value, maximum_value]

func change_max_value(v): #current_value != max_value
	self.max_value = v
	maximum_value = v
	if(get_node("Label")!=null):
		get_node("Label").text = "%s / %s" % [current_value, maximum_value]

func animate_value(start, end):
	get_node("Tween").interpolate_property(self, "value", start, end, 0.6, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	get_node("Tween").start()