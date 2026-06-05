extends Camera2D

@export var shake_strength := 0.0
@export var shake_fade := 5.0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		
		offset = Vector2(
			rng.randf_range(-shake_strength, shake_strength),
			rng.randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO

func shake(power: float):
	shake_strength = power
