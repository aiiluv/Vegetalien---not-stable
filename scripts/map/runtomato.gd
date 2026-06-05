extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer
@onready var skip_btn: Button = $"Skip button"

func _ready():
	if video:
		video.finished.connect(_on_video_finished)
		video.play()

	if skip_btn:
		skip_btn.pressed.connect(_on_skip_pressed)

func _on_video_finished():
	print("🎬 CUTSCENE SELESAI")
	go_to_main()

func _on_skip_pressed():
	go_to_main()

func go_to_main():
	# Tandai bahwa pemain datang dari cutscene
	EventBus.mark_cutscene_done()
	
	# Hentikan video untuk menghindari layar hitam
	if video:
		video.stop()

	# Pindah ke scene utama
	get_tree().change_scene_to_file("res://scenes/main.tscn")
