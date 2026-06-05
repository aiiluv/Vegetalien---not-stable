extends Area2D

@export var speed := 600
@export var damage := 1
@export var knockback_power := 60.0

var direction := Vector2.ZERO # Akan diisi oleh Player saat di-instantiate

func _process(delta):
	# Peluru bergerak ke arah yang sudah ditentukan
	position += direction * speed * delta

func _on_body_entered(body):
	# Abaikan jika peluru menyentuh Player itu sendiri
	if body.is_in_group("player"): 
		return
		
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(global_position, knockback_power)
		
		var game_manager = get_tree().current_scene.get_node_or_null("GameManager")
		if game_manager and game_manager.has_method("play_sfx_shoot"):
			game_manager.play_sfx_shoot()
		queue_free()

	if body.is_in_group("border"):
		queue_free()
