extends CharacterBody2D

# --- CONFIGURATION ---
@export var speed: float = 100
@export var max_health: int = 10
@export var knockback_power: float = 150.0
@export var knockback_friction: float = 80.0

# --- STATE ---
var current_health: int
var player_near: bool = false
var is_active: bool = false
var is_dead: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

# CUTSCENE STATE (ADDED)
var cutscene_played: bool = false

# --- NODE REFERENCES ---
@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $Area2D
@onready var damage_area: Area2D = get_node_or_null("DamageArea")
@onready var label: Label = $Label
@onready var health_bar: TextureProgressBar = $HealthBar


func _ready():
	# Jika gajah sudah dikalahkan sebelumnya, langsung hapus dari scene
	if EventBus and EventBus.elephant_defeated:
		print("🐘 Elephant already defeated, removing from scene.")
		queue_free()
		return

	add_to_group("enemies")
	current_health = max_health
	update_health_bar()
	health_bar.visible = false

	if player == null:
		push_warning("Player tidak ditemukan di group 'player'.")

	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)

	label.visible = false

	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_body_entered)

	var dialogic = get_node_or_null("/root/Dialogic")
	if dialogic and not dialogic.signal_event.is_connected(_on_dialog_signal):
		dialogic.signal_event.connect(_on_dialog_signal)

# ==========================================================
# UPDATE HEALTH BAR
# ==========================================================
func update_health_bar():
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health


# ==========================================================
# SIGNAL DARI DIALOGIC UNTUK MEMULAI CHASING
# ==========================================================
func _on_dialog_signal(arg: String):
	if arg == "start_enemy":
		is_active = true
		label.visible = false
		health_bar.visible = true

		if interact_area:
			interact_area.queue_free()


# ==========================================================
# INTERACTION
# ==========================================================
func _process(delta):
	if player_near and not is_active and Input.is_action_just_pressed("interact"):
		start_dialog()


func start_dialog():
	if Dialogic:
		Dialogic.start("elepant")


func _on_body_entered(body):
	if body.is_in_group("player") and not is_active:
		player_near = true
		label.visible = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		label.visible = false


# ==========================================================
# MOVEMENT & CHASING
# ==========================================================
func _physics_process(delta):
	if not is_active or player == null or is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = (player.global_position - global_position).normalized()

	# Prioritaskan knockback
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
	else:
		velocity = direction * speed

	# Flip sprite
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	move_and_slide()

	# Reduksi knockback
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO, knockback_friction * delta
	)


# ==========================================================
# DAMAGE KE PLAYER
# ==========================================================
func _on_damage_area_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(global_position)


# ==========================================================
# DAMAGE DARI BULLET
# ==========================================================
func take_damage(from_position: Vector2, power: float):
	if is_dead:
		return

	current_health -= 1
	update_health_bar()
	print("Elepant HP:", current_health)

	apply_knockback(from_position, power)
	await flash_red()

	if current_health <= 0:
		die()


# ==========================================================
# KNOCKBACK
# ==========================================================
func apply_knockback(from_position: Vector2, power: float):
	var dir = (global_position - from_position).normalized()
	knockback_velocity = dir * power


# ==========================================================
# VISUAL FEEDBACK
# ==========================================================
func flash_red():
	sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)


# ==========================================================
# ENEMY MATI + CUTSCENE
# ==========================================================
func die():
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	print("☠️ ELEPHANT MATI")

	# Tandai bahwa gajah telah dikalahkan
	if EventBus:
		EventBus.finish_elephant_fight()

	if not cutscene_played:
		cutscene_played = true
		start_cutscene()
	else:
		queue_free()

# ==========================================================
# CUTSCENE SYSTEM (ADDED)
# ==========================================================
func start_cutscene():
	is_active = false

	print("🎬 START CUTSCENE")

	# freeze player (kalau masih ada di scene ini)
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.set_physics_process(false)

	# pindah scene
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/cutscene/RunTomato.tscn")


# ==========================================================
# CUTSCENE END → BACK TO GAMEPLAY
# ==========================================================
func _on_cutscene_end(arg: String):
	if arg == "cutscene_end":
		print("🎬 CUTSCENE SELESAI")
		Dialogic.start("")

		var player_node = get_tree().get_first_node_in_group("player")
		if player_node:
			player_node.set_physics_process(true)

		queue_free()
