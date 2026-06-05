extends CharacterBody2D

# ===== INTERACTION =====
var player_near = false
var can_interact = false

# ===== MOVEMENT =====
@export var move_speed := 80
@export var stop_distance := 40      # jarak berhenti ke elephant
@export var wait_distance := 120     # jarak max dari player sebelum nunggu

var is_moving := false

# ===== REFERENCES =====
@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var target: Node2D = get_tree().get_first_node_in_group("elephant")

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	$Label.visible = false

	# aktif setelah game mulai
	if EventBus:
		EventBus.game_started.connect(_on_game_started)

	# dengar dialog
	if Dialogic:
		Dialogic.signal_event.connect(_on_dialog_signal)

# ==========================================================
# AKTIF SETELAH TUTORIAL
# ==========================================================
func _on_game_started():
	can_interact = true

# ==========================================================
# INTERACT
# ==========================================================
func _process(delta):
	if not can_interact:
		return

	if player_near and Input.is_action_just_pressed("interact"):
		start_dialog()

# ==========================================================
# DIALOG
# ==========================================================
func start_dialog():
	if Dialogic:
		Dialogic.start("meet_carrot")

func _on_dialog_signal(arg: String):
	if arg == "follow_carrot":
		start_follow()

# ==========================================================
# START FOLLOW
# ==========================================================
func start_follow():
	print("Carrot mulai jalan (tunggu player mode)")
	is_moving = true
	can_interact = false
	$Label.visible = false

# ==========================================================
# MOVEMENT AI
# ==========================================================
func _physics_process(delta):
	if not is_moving or target == null or player == null:
		return

	# ===== CEK JARAK KE PLAYER =====
	var dist_to_player = global_position.distance_to(player.global_position)

	if dist_to_player > wait_distance:
		# 🔥 STOP (nunggu player)
		velocity = Vector2.ZERO
		move_and_slide()
		print("Carrot nunggu player...")
		return

	# ===== GERAK KE ELEPHANT =====
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * move_speed

	# flip sprite
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x > 0

	move_and_slide()

	# ===== SAMPAI =====
	if global_position.distance_to(target.global_position) < stop_distance:
		is_moving = false
		velocity = Vector2.ZERO
		print("Carrot sampai di Elephant 🐘")

		# 🔥 trigger dialog elephant
		if Dialogic:
			Dialogic.start("elepant_intro")

# ==========================================================
# AREA DETECTION
# ==========================================================
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		if can_interact:
			$Label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		$Label.visible = false
