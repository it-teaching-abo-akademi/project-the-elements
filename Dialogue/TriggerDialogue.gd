extends Area2D

export(String, FILE, "*.tscn")  var target_stage

onready var dialogue : DialogueAction = get_node("/root/MainStage/CanvasLayer/DialogueAction")

var area_entered = false
var dialogue_triggered = false

func _ready():
	pass
	
	
func _process(delta):
	if area_entered and not dialogue_triggered:
		get_tree().paused = true
		dialogue.start()
		yield(dialogue,"dialogue_finished")
		get_tree().paused = false
		dialogue_triggered = true


func _on_TriggerDialogue_body_entered(body):
	if "Player" in body.name:
		area_entered = true


func _on_TriggerDialogue_body_exited(body):
	if "Player" in body.name:
		area_entered = false
