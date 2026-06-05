extends Camera2D

@export var player: Node2D

func _ready():
	zoom = Vector2(0.2, 0.2)

func _process(delta):
	if player:
		global_position = player.global_position
