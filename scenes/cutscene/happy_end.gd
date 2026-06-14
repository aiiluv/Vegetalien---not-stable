extends Control

@onready var video = $VideoStreamPlayer

func _ready():
	video.finished.connect(_on_video_finished)
	video.play()

func _on_video_finished():
	go_to_main()

func _on_button_pressed():
	go_to_main()

func go_to_main():
	# 1. JANGAN PAKAI .stop()! Ubah ke paused agar audio decoder-nya berhenti aman
	video.paused = true
	
	# 2. Sembunyikan video agar tidak berkedip di layar
	video.visible = false
	
	# 3. Lempar bus-nya ke antah berantah agar soundcard langsung terbebas
	video.bus = "MutedVideoBusTemporary" 
	
	# 4. Hancurkan node video dari memori
	video.queue_free()
	
	# 5. Pancing ulang detak jantung BGM kamu setelah jalurnya bersih
	if Bgm:
		Bgm.volume_db = 0
		Bgm.stop()
		# Beri jeda 1 frame sebelum play ulang agar hardware soundcard segar kembali
		await get_tree().process_frame
		Bgm.play()

	# 6. Pindah ke scene game utama
	get_tree().change_scene_to_file("res://scenes/main.tscn")
