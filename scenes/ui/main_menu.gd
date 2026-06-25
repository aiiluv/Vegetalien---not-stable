extends Control

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/cutscene/backstory.tscn")

func _on_about_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/about.tscn")

func _on_character_info_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/character_info.tscn")

#====================================================================================

# Atur seberapa jauh karakter bergeser
@export var move_strength: float = 15.0

# Simpan posisi awal asli masing-masing karakter
var tomat_start_pos: Vector2
var carrot_start_pos: Vector2
var mushroom_start_pos: Vector2

func _ready():
	# Ambil posisi awal mereka saat menu pertama kali dibuka
	if $AnimatedTomat: tomat_start_pos = $AnimatedTomat.position
	if $AnimatedCarrot: carrot_start_pos = $AnimatedCarrot.position
	if $AnimatedMushroom: mushroom_start_pos = $AnimatedMushroom.position


func _process(delta):
	var center_screen = get_viewport_rect().size / 2.0
	var mouse_pos = get_local_mouse_position()
	var mouse_offset = (mouse_pos - center_screen).normalized()
	
	# ===== LOGIKA GERAK PARALLAX =====
	if $AnimatedTomat:
		var target_pos = tomat_start_pos + (mouse_offset * move_strength)
		$AnimatedTomat.position = $AnimatedTomat.position.lerp(target_pos, 5.0 * delta)
		# FLIP: Jika mouse di sebelah kiri tomat, flip aktif (menghadap kiri)
		$AnimatedTomat.flip_h = mouse_pos.x < $AnimatedTomat.position.x
		
	if $AnimatedCarrot:
		var target_pos = carrot_start_pos + (mouse_offset * -move_strength)
		$AnimatedCarrot.position = $AnimatedCarrot.position.lerp(target_pos, 5.0 * delta)
		# FLIP: Jika mouse di sebelah kiri wortel, flip aktif
		$AnimatedCarrot.flip_h = mouse_pos.x < $AnimatedCarrot.position.x
		
	if $AnimatedMushroom:
		var target_pos = mushroom_start_pos + (mouse_offset * (move_strength * 0.5))
		$AnimatedMushroom.position = $AnimatedMushroom.position.lerp(target_pos, 5.0 * delta)
		# FLIP: Jika mouse di sebelah kiri jamur, flip aktif
		$AnimatedMushroom.flip_h = mouse_pos.x > $AnimatedMushroom.position.x
