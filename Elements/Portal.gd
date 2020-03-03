extends Area2D


export(NodePath)  var target_portal

var area_entered = false

var player = null

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		area_entered = true
		player = body


func _on_Area2D_body_exited(body):
	if "Player" in body.name:
		area_entered = false
		player = null
		
func _process(delta):
	if Input.is_action_just_pressed("ctrl") and area_entered:
		player.position = get_node(target_portal).position
