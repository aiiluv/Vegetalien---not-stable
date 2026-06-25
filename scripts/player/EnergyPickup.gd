extends Area2D

signal picked_up

@export var stamina_amount: float = 20.0

func _ready():
	add_to_group("energy")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("add_stamina"):
			body.add_stamina(stamina_amount)

		#PANGGIL SFX ENERGI DI SINI (SUDAH DI DALAM FUNGSI)
		var game_manager = get_tree().current_scene.get_node_or_null("GameManager")
		if game_manager and game_manager.has_method("play_sfx_energy"):
			game_manager.play_sfx_energy()

		emit_signal("picked_up")
		queue_free()
