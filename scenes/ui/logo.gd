extends Sprite2D

#POSISI AWAL
var start_position: Vector2

#max gambar bergeser
@export var max_offset: float = 30.0

func _ready() -> void:
	start_position = position

func _process(delta):
	#ambil ukuran layar
	var center_screen = get_viewport_rect().size/2
	
	#hitung seberapa jauh kursor mouse dari tengah layar
	var mouse_offset = (get_viewport().get_mouse_position() - center_screen) / center_screen
	
	#hitung posisi target baru berdasarkan posisi mouse tadi
	var target_pos = start_position + (mouse_offset * max_offset)
	
	#gerakkan title ke posisi target
	position = position.lerp(target_pos, 5.0 * delta)
