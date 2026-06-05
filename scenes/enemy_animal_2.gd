extends CharacterBody2D

# ==========================================================
# CONFIGURATION
# ==========================================================
@export var speed: float = 100.0
@export var max_health: int = 3
@export var knockback_power: float = 150.0
@export var knockback_friction: float = 80.0

# Signal dikirim ketika enemy mati (misalnya untuk melanjutkan tutorial)
signal tutorial_done

# ==========================================================
# STATE
# ==========================================================
var current_health: int
var is_active: bool = false   # Enemy hanya mengejar jika true
var is_dead: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var player: Node2D = null

# ==========================================================
# NODE REFERENCES
# ==========================================================
@onready var sprite: Sprite2D = $Sprite2D
@onready var damage_area: Area2D = get_node_or_null("DamageArea")
@onready var health_bar: TextureProgressBar = get_node_or_null("HealthBar")

# ==========================================================
# READY
# ==========================================================
func _ready():
	add_to_group("enemies")
	current_health = max_health
	update_health_bar()

	# Cari player dari group
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Player tidak ditemukan di group 'player'.")

	# Hubungkan signal dari Dialogic untuk memulai chasing
	var dialogic = get_node_or_null("/root/Dialogic")
	if dialogic:
		if not dialogic.signal_event.is_connected(_on_dialog_signal):
			dialogic.signal_event.connect(_on_dialog_signal)
			print("Enemy berhasil terhubung ke Dialogic signal.")
	else:
		push_warning("Dialogic tidak ditemukan di Autoload.")

	# Hubungkan DamageArea untuk memberikan damage ke player
	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_body_entered)
	else:
		push_warning("DamageArea tidak ditemukan!")

# ==========================================================
# UPDATE HEALTH BAR
# ==========================================================
func update_health_bar():
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	else:
		push_warning("HealthBar tidak ditemukan! Tambahkan TextureProgressBar bernama 'HealthBar'.")

# ==========================================================
# SIGNAL DARI DIALOGIC UNTUK MEMULAI CHASING
# ==========================================================
func _on_dialog_signal(arg: String):
	print("Signal diterima dari Dialogic:", arg)
	if arg == "tutorial_end":
		start_chasing()

func start_chasing():
	is_active = true
	print("Enemy mulai mengejar player!")

# ==========================================================
# MOVEMENT & CHASING
# ==========================================================
func _physics_process(delta):
	if not is_active or is_dead or player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = (player.global_position - global_position).normalized()

	# Prioritaskan knockback jika masih ada
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
	else:
		velocity = direction * speed

	# Flip sprite berdasarkan arah gerak
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	move_and_slide()

	# Reduksi knockback secara bertahap
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
# DAMAGE DARI BULLET (SESUI DENGAN SCRIPT BULLET MILIKMU)
# ==========================================================
func take_damage(from_position: Vector2, power: float = 60.0):
	if is_dead:
		return

	current_health -= 1
	update_health_bar()
	print("Enemy HP:", current_health)

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
# VISUAL FEEDBACK (FLASH RED)
# ==========================================================
func flash_red():
	sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)

# ==========================================================
# ENEMY MATI
# ==========================================================
func die():
	is_dead = true
	print("Enemy mati!")
	EventBus.emit_signal("tutorial_done") # Mengirim signal ke sistem lain jika diperlukan
	queue_free()
