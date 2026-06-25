extends CharacterBody2D

# ===== MOVEMENT =====
@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

# ===== SHOOTING SCENE =====
@export var bullet_scene: PackedScene

# ===== STAMINA SYSTEM =====
@export var max_stamina := 100.0
var current_stamina := 0.0
@onready var stamina_bar: TextureProgressBar = get_node_or_null("/root/Main/CanvasLayer/Control/ProgressBar")

# ===== HP SYSTEM =====
@export var max_hp := 5
var current_hp := 5
var is_invincible: bool = false

# ===== STATES =====
var knockback_velocity: Vector2 = Vector2.ZERO
var is_dead: bool = false


func _ready():
	add_to_group("player")
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = current_stamina
	
	# ===== KONTROL PERUBAHAN SPRITE TOMAT =====
	var normal_sprite = get_node_or_null("AnimatedSprite2D")
	var rotten_sprite = get_node_or_null("AnimatedRotten")
	
	if EventBus.after_cutscene:
		# Jika cutscene Elephant sudah selesai, pakai tomat busuk
		if normal_sprite: normal_sprite.visible = false
		if rotten_sprite: rotten_sprite.visible = true
	else:
		# Jika belum, pakai tomat segar normal
		if normal_sprite: normal_sprite.visible = true
		if rotten_sprite: rotten_sprite.visible = false

func _physics_process(delta):
	if is_dead:
		return

	handle_movement(delta)
	handle_animation()
	handle_shooting()
	move_and_slide()


func handle_movement(delta):
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800.0 * delta)
		return

	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_dir = input_dir.normalized()

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# SFX Langkah kaki jalan
	var game_manager = null
	if is_inside_tree():
		game_manager = get_tree().root.get_node_or_null("Main/GameManager")

	if game_manager and game_manager.has_method("play_sfx_walk"):
		if velocity.length() > 10:
			game_manager.play_sfx_walk(true)
		else:
			game_manager.play_sfx_walk(false)


func handle_animation():
	# Ambil referensi kedua sprite
	var normal_sprite = get_node_or_null("AnimatedSprite2D")
	var rotten_sprite = get_node_or_null("AnimatedRotten")
	
	# Tentukan sprite mana yang aktif saat ini
	var active_sprite : AnimatedSprite2D = null
	if normal_sprite and normal_sprite.visible:
		active_sprite = normal_sprite
	elif rotten_sprite and rotten_sprite.visible:
		active_sprite = rotten_sprite

	# Jalankan animasi pada sprite yang aktif
	if active_sprite:
		if velocity.x != 0:
			active_sprite.flip_h = velocity.x < 0
		if velocity.length() > 10:
			active_sprite.play("walk")
		else:
			active_sprite.play("idle")


func handle_shooting():
	if Input.is_action_just_pressed("shoot"):
		if current_stamina >= max_stamina:
			var game_manager = null
			if is_inside_tree():
				game_manager = get_tree().root.get_node_or_null("Main/GameManager")
				
			if game_manager and game_manager.has_method("play_sfx_shoot"):
				game_manager.play_sfx_shoot()

			current_stamina = 0.0
			if stamina_bar:
				stamina_bar.value = current_stamina
			
			shoot()
		else:
			print("Stamina belum penuh!")

func shoot():
	var shoot_point = get_node_or_null("ShootPoint")
	if shoot_point == null or bullet_scene == null:
		print("ERROR: ShootPoint atau BulletScene belum diatur!")
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = shoot_point.global_position
	
	# HITUNG ARAH KE MOUSE
	var direction = (get_global_mouse_position() - shoot_point.global_position).normalized()
	bullet.direction = direction
	bullet.rotation = direction.angle()

func add_stamina(amount: float):
	current_stamina = clamp(current_stamina + amount, 0, max_stamina)
	if stamina_bar:
		var tween = create_tween()
		tween.tween_property(stamina_bar, "value", current_stamina, 0.2)


func take_damage(from_position: Vector2, power: float = 400.0):
	if is_invincible or is_dead:
		return
	is_invincible = true
	current_hp -= 1

	var direction = (global_position - from_position).normalized()
	knockback_velocity = direction * power

	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.modulate = Color(1, 0.2, 0.2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)

	var game_manager = null
	if is_inside_tree():
		game_manager = get_tree().root.get_node_or_null("Main/GameManager")

	if game_manager and game_manager.has_method("play_sfx_hurt"):
		game_manager.play_sfx_hurt()

	var heart_ui = get_node_or_null("/root/Main/CanvasLayer/HBoxContainer")
	if heart_ui and heart_ui.has_method("take_damage"):
		heart_ui.take_damage(1)

	if current_hp <= 0:
		die()
		return
	await get_tree().create_timer(0.5).timeout
	is_invincible = false
	
	# Cari sprite mana yang sedang dipakai untuk diberi efek merah
	var normal_sprite = get_node_or_null("AnimatedSprite2D")
	var rotten_sprite = get_node_or_null("AnimatedRotten")
	var active_sprite = normal_sprite if (normal_sprite and normal_sprite.visible) else rotten_sprite

	if active_sprite:
		active_sprite.modulate = Color(1, 0.2, 0.2)
		await get_tree().create_timer(0.1).timeout
		active_sprite.modulate = Color(1, 1, 1)


func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	
	var game_manager = null
	if is_inside_tree():
		game_manager = get_tree().root.get_node_or_null("Main/GameManager")
		
	if game_manager and game_manager.has_method("play_sfx_walk"):
		game_manager.play_sfx_walk(false)
	if EventBus:
		EventBus.emit_signal("player_died")
