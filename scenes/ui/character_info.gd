extends Control

func _ready() -> void:
	if %BookClose : %BookClose.visible = true
	if %BookChara : %BookChara.visible = false

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_book_chara_pressed() -> void:
	if %BookChara and %BookClose:
		%BookChara.visible = false
		%BookClose.visible = true

func _on_book_close_pressed() -> void:
	if %BookChara and %BookClose:
		%BookChara.visible = true
		%BookClose.visible = false
