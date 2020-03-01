extends Area2D


export(String, FILE, "*.tscn")  var target_stage

var area_entered = false

onready var animation_player = $AnimationPlayer

func _ready():
	global.current_scene = get_tree().get_current_scene()

func _on_ChangeStage_body_entered(body):
	if "Player" in body.name:
		area_entered = true
		

func _on_ChangeStage_body_exited(body):
	if "Player" in body.name:
		area_entered = false
	
	
func _process(delta):
	if Input.is_action_pressed("ctrl") and area_entered:
		get_tree().change_scene(target_stage)



