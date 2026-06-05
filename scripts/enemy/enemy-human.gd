extends CharacterBody2D

@export var speed := 100
@export var stun_duration := 0.3
@export var health := 3

# 🔥 BEDAIN ENEMY
@export var enemy_type: String = "tree" # "tutorial" atau "tree"

@onready var sprite: Sprite2D = $Sprite2D
var target: Node2D = null

# ===== STATE =====
var is_stunned := false
var is_dead := false
var is_active := false

# ===== KNOCKBACK =====
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_friction := 120.0

@onready var damage_area: Area2D = get_node_or_null("DamageArea")

func _ready():
	add_to_group("enemies")

	call_deferred("find_player")

	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_body_entered)

	# 🔥 CONNECT SESUAI TYPE
	if EventBus:
		if enemy_type == "tutorial":
			EventBus.spawn_enemy_tutorial.connect(_on_spawn_tutorial)

		elif enemy_type == "tree":
			EventBus.spawn_enemy_tree.connect(_on_spawn_tree)

	# ⛔ MATI DI AWAL
	set_physics_process(false)

func find_player():
	target = get_tree().get_first_node_in_group("player")

# ==========================================================
# AKTIVASI (FIX)
# ==========================================================
func _on_spawn_tutorial():
	if enemy_type == "tutorial":
		activate_enemy()

func _on_spawn_tree():
	if enemy_type == "tree":
		activate_enemy()

func activate_enemy():
	is_active = true
	set_physics_process(true)
	print("Enemy aktif:", enemy_type)

# ==========================================================
# PHYSICS
# ==========================================================
func _physics_process(delta):
	if is_dead:
		return

	if not is_active:
		return

	if target == null:
		find_player()
		return

	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = (target.global_position - global_position).normalized()

	if knockback_velocity.length() > 1:
		velocity = knockback_velocity
	else:
		velocity = direction * speed

	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	move_and_slide()

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO, knockback_friction * delta
	)

# ==========================================================
# DAMAGE
# ==========================================================
func take_damage(from_position: Vector2, power: float):
	if is_dead:
		return

	health -= 1
	apply_knockback(from_position, power)

	if health <= 0:
		die()

func die():
	is_dead = true

	if EventBus:
		EventBus.emit_signal("enemy_died")

	queue_free()

func _on_damage_area_body_entered(body):
	if is_dead or not is_active:
		return

	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(global_position)

# ==========================================================
# EFFECT
# ==========================================================
func apply_knockback(from_position: Vector2, power: float):
	var dir = (global_position - from_position).normalized()
	knockback_velocity = dir * power * 1.5

	flash_red()
	start_stun()

func start_stun():
	if is_stunned:
		return

	is_stunned = true
	sprite.modulate = Color(0.5, 0.7, 1.0)

	await get_tree().create_timer(stun_duration).timeout

	is_stunned = false
	sprite.modulate = Color(1, 1, 1)

func flash_red():
	sprite.modulate = Color(1, 0.2, 0.2)

	await get_tree().create_timer(0.1).timeout

	if is_stunned:
		sprite.modulate = Color(0.5, 0.7, 1.0)
	else:
		sprite.modulate = Color(1, 1, 1)
