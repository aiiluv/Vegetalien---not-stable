extends CharacterBody2D

# ===== INTERACTION =====
var player_near = false
var can_interact = false
var is_following_player = false # Status baru: apakah sudah ikut player?

# ===== MOVEMENT =====
@export var move_speed := 100      # Kecepatan wortel saat membuntuti
@export var follow_distance := 180.0  # Jarak aman/berjarak dari player (Wortel akan berhenti jika sedekat ini)

var is_moving := false

# ===== REFERENCES =====
@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var target: Node2D = get_tree().get_first_node_in_group("elephant")

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	$Label.visible = false

	# Dengarkan sinyal dialog dari Dialogic
	if Dialogic:
		Dialogic.signal_event.connect(_on_dialog_signal)
		
	# ===== KONTROL PERUBAHAN SPRITE WORTEL BUSUK =====
	if EventBus and EventBus.after_cutscene:
		if $Sprite2D: $Sprite2D.visible = false
		if $rotten: $rotten.visible = true
	else:
		if $Sprite2D: $Sprite2D.visible = true
		if $rotten: $rotten.visible = false


func _process(delta):
	# Cek apakah Enemy 1 dan Enemy 2 sudah mati di map sebelum mengizinkan interaksi
	if not can_interact:
		check_enemies_status()
		return

	if player_near and Input.is_action_just_pressed("interact"):
		start_dialog()


# FUNGSI CEK ENEMY (Menggunakan Scene Unique Name absolut dari Root)
func check_enemies_status():
	# Memanggil Unique Name secara absolut dari Root Scene Utama ("Main")
	var enemy1 = get_node_or_null("/root/Main/%EnemyAnimal")
	var enemy2 = get_node_or_null("/root/Main/%EnemyAnimal2")
	
	# Jika kedua node musuh sudah tidak ada (null) di map, berarti keduanya sudah kalah!
	if enemy1 == null and enemy2 == null:
		can_interact = true
		if player_near:
			$Label.visible = true


func start_dialog():
	if Dialogic:
		Dialogic.start("meet_carrot")


func _on_dialog_signal(arg: String):
	# Pasang argumen sinyal dari Dialogic setelah dialognya selesai
	if arg == "follow_player" or arg == "follow_carrot":
		start_follow_player()


func start_follow_player():
	print("Carrot sekarang resmi mengikuti Player!")
	is_following_player = true
	can_interact = false
	$Label.visible = false


# MOVEMENT AI (Membuntuti Player)
func _physics_process(delta):
	# AI hanya aktif jika status mengikuti sudah menyala dan player ditemukan
	if not is_following_player or player == null:
		return

	# 1. Hitung jarak dan arah ke Player
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# 2. Logika Berjarak: Jika player berjalan menjauh melebihi batas 'follow_distance'
	if distance_to_player > follow_distance:
		var dir = (player.global_position - global_position).normalized()
		
		# Wortel bergerak mendekati posisi player
		velocity = dir * move_speed
		
		# Tentukan node sprite mana yang saat ini sedang aktif / visible
		var active_sprite = $Sprite2D if ($Sprite2D and $Sprite2D.visible) else $rotten
		
		# Flip sprite wortel menghadap ke arah jalannya
		if velocity.x != 0 and active_sprite:
			active_sprite.flip_h = velocity.x < 0
				
		move_and_slide()
	else:
		# Jika sudah cukup dekat dan berjarak pas, wortel diam di tempat
		velocity = Vector2.ZERO
		move_and_slide()


# AREA DETECTION
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		if can_interact:
			$Label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		$ Label.visible = false
