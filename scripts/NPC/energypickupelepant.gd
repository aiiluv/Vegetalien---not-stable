extends Node2D

@export var energy_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var max_energy: int = 5
@export var is_active: bool = true  # Bisa diaktifkan/dinonaktifkan

var spawn_points: Array[Marker2D] = []
var rng := RandomNumberGenerator.new()
var current_energy_count: int = 0  # Hanya menghitung energy milik spawner ini

func _ready():
	rng.randomize()

	# Ambil semua Marker2D sebagai titik spawn
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	if spawn_points.is_empty():
		push_error("Tidak ada Marker2D sebagai titik spawn!")
		return

	# Spawn awal
	for i in range(max_energy):
		spawn_energy()

	# Jalankan loop spawn
	spawn_loop()

func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		if is_active and current_energy_count < max_energy:
			spawn_energy()

func spawn_energy():
	if energy_scene == null:
		push_error("Energy Scene belum di-assign!")
		return

	if current_energy_count >= max_energy:
		return

	# Pilih titik spawn secara acak
	var point = spawn_points[rng.randi_range(0, spawn_points.size() - 1)]

	var energy = energy_scene.instantiate()
	energy.global_position = point.global_position
	get_tree().current_scene.add_child(energy)

	current_energy_count += 1

	# Hubungkan signal saat energy diambil
	if energy.has_signal("collected"):
		energy.collected.connect(_on_energy_collected)

	print("Energy spawn di:", point.global_position)

# Dipanggil saat energy diambil oleh player
func _on_energy_collected():
	current_energy_count = max(0, current_energy_count - 1)

# Fungsi untuk mengaktifkan spawner (misalnya setelah teleport)
func activate_spawner():
	is_active = true
	print("Spawner diaktifkan")

# Fungsi untuk menonaktifkan spawner
func deactivate_spawner():
	is_active = false
	print("Spawner dinonaktifkan")
