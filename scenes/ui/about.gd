extends Control

func _ready() -> void:
	#pertama kali masuk, book close
	if %BookClose: %BookClose.visible = true
	if %BookAbout: %BookAbout.visible = false



func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_book_about_pressed() -> void:
	if %BookAbout and %BookClose:
		%BookClose.visible = true
		%BookAbout.visible = false


func _on_book_close_pressed() -> void:
	if %BookAbout and %BookClose:
		%BookClose.visible = false
		%BookAbout.visible = true
