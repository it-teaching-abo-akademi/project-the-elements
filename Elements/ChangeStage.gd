extends Area2D


export(String, FILE, "*.tscn")  var target_stage

var area_entered = false

onready var animation_player = $AnimationPlayer

func _ready():
	global.current_scene = target_stage
	animation_player.play_backwards("fade")

func _on_ChangeStage_body_entered(body):
	if "Player" in body.name:
		area_entered = true
		

func _on_ChangeStage_body_exited(body):
	if "Player" in body.name:
		area_entered = false
	
	
func _process(delta):
	if Input.is_action_pressed("ctrl") and area_entered:
		if target_stage == null or target_stage == "":
			var current_stage = str(get_tree().get_current_scene().get_path())
			var length = current_stage.length()
			target_stage = "res://Scenes/Stage" + str(current_stage.substr(length-1,length).to_int()+1) + ".tscn"
		animation_player.play("fade")
		yield(animation_player,"animation_finished")
		get_tree().change_scene(target_stage)
		