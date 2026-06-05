extends Node2D

@export var energy_scene: PackedScene

@onready var marker1 = $Marker2D_1
@onready var marker2 = $Marker2D_2
@onready var marker3 = $Marker2D_3

func _ready():
	Dialogic.signal_event.connect(_on_signal)

func _on_signal(arg):
	if arg == "energy_spawn":
		spawn()

func spawn():
	spawn_energy(marker1.global_position)
	spawn_energy(marker2.global_position)
	spawn_energy(marker3.global_position)

func spawn_energy(pos):
	var energy = energy_scene.instantiate()
	energy.global_position = pos
	add_child(energy)
