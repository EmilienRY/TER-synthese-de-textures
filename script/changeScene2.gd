extends Node3D

func _input(event):
	if event.is_action_pressed("ui_select_1"):
		get_tree().change_scene_to_file("res://scenes/sceneDeBase.tscn")
