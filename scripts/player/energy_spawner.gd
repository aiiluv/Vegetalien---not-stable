extends Node2D

@export var energy_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var max_energy: int = 5

var spawn_points: Array[Marker2D] = []
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	# Ambil semua Marker2D sebagai titik spawn
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	# Mulai proses spawn
	spawn_loop()

func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		spawn_energy()

func spawn_energy():
	if energy_scene == null:
		push_error("Energy Scene belum di-assign!")
		return

	# Batasi jumlah energy di map
	if get_tree().get_nodes_in_group("energy").size() >= max_energy:
		return

	if spawn_points.is_empty():
		push_error("Tidak ada Marker2D sebagai titik spawn!")
		return

	# Pilih titik spawn secara acak
	var point = spawn_points[rng.randi_range(0, spawn_points.size() - 1)]

	var energy = energy_scene.instantiate()
	energy.global_position = point.global_position
	get_tree().current_scene.add_child(energy)


func _on_to_pemukiman_spawner_pemukiman() -> void:
	pass # Replace with function body.
