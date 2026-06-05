extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer
@onready var skip_btn: Button = $"Skip button"

func _ready():
	video.finished.connect(_on_video_finished)
	video.play()

	skip_btn.pressed.connect(_on_button_pressed)

func _on_video_finished():
	go_to_main()


func _on_button_pressed() -> void:
	go_to_main()


func go_to_main():
	# 🔥 SET FLAG CUTSCENE SELESAI
	EventBus.after_cutscene = true

	get_tree().change_scene_to_file("res://scenes/main.tscn")
