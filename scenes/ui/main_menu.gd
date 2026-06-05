extends Control

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/cutscene/backstory.tscn")

func _on_about_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/about.tscn")

func _on_character_info_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/character_info.tscn")
