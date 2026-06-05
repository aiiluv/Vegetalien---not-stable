extends HBoxContainer

@export var max_health := 3
var current_health := 3

@export var heart_texture: Texture2D

func _ready():
	print("READY KEJALAN")
	create_hearts()

func create_hearts():
	for i in range(max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.custom_minimum_size = Vector2(50, 48)
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		add_child(heart)

func take_damage(amount):
	for i in range(amount):
		if get_child_count() > 0:
			var heart = get_child(get_child_count() - 1)

			# 💥 pakai Tween buat animasi
			var tween = create_tween()

			# Pop (gede dikit)
			tween.tween_property(heart, "scale", Vector2(1.3, 1.3), 0.1)

			# Balik normal
			tween.tween_property(heart, "scale", Vector2(1, 1), 0.1)

			# Fade + shrink
			tween.parallel().tween_property(heart, "modulate:a", 0.0, 0.2)
			tween.parallel().tween_property(heart, "scale", Vector2(0.5, 0.5), 0.2)

			# Tunggu animasi selesai
			await tween.finished

			heart.queue_free()

	current_health -= amount
	current_health = max(current_health, 0)

func heal(amount):
	for i in range(amount):
		if get_child_count() < max_health:
			var heart = TextureRect.new()
			heart.texture = heart_texture
			heart.custom_minimum_size = Vector2(24, 24)
			heart.scale = Vector2(0, 0)
			add_child(heart)

			var tween = create_tween()
			tween.tween_property(heart, "scale", Vector2(1, 1), 0.2)

	current_health += amount
	current_health = min(current_health, max_health)
