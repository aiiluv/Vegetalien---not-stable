extends Area2D

@export var spawn_point_path: NodePath
@export var timeline_name: String = "to_pemukiman"

signal spawner_pemukiman

var player_ref: Node2D = null
var dialog_started := false
var can_interact := false  # 🔥 Dikunci di awal

var spawn_point: Marker2D


# ==========================================================
# READY
# ==========================================================
func _ready():
	# Ambil spawn point dengan aman
	if spawn_point_path != NodePath():
		spawn_point = get_node_or_null(spawn_point_path)

	if spawn_point == null:
		push_warning("⚠️ Spawn point tidak ditemukan!")

	# Hubungkan sinyal body_entered
	body_entered.connect(_on_body_entered)

	# 🔥 Cek apakah fight gajah sudah selesai
	if EventBus:
		can_interact = EventBus.elephant_defeated

		if not EventBus.elephant_fight_finished.is_connected(_on_elephant_fight_finished):
			EventBus.elephant_fight_finished.connect(_on_elephant_fight_finished)

	# Dialogic signals
	if Dialogic:
		if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
			Dialogic.signal_event.connect(_on_dialogic_signal)


# ==========================================================
# AREA ENTER
# ==========================================================
func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	# 🔒 Jika fight belum selesai, tolak akses
	if not can_interact:
		print("🚫 Pemukiman masih terkunci! Selesaikan fight dengan gajah terlebih dahulu.")
		return

	if dialog_started:
		return

	dialog_started = true
	player_ref = body

	print("✅ PLAYER ENTER + INTERACT OK")

	# Nonaktifkan pergerakan player sementara
	if player_ref.has_method("set_physics_process"):
		player_ref.set_physics_process(false)

	start_dialog()


# ==========================================================
# EVENT: FIGHT GAJAH SELESAI
# ==========================================================
func _on_elephant_fight_finished():
	can_interact = true
	print("🔓 Pemukiman sekarang bisa diakses!")


# ==========================================================
# START DIALOG
# ==========================================================
func start_dialog():
	print("💬 DIALOG START:", timeline_name)

	if Dialogic:
		# Hubungkan timeline_ended sebagai one-shot
		if Dialogic.has_signal("timeline_ended"):
			Dialogic.timeline_ended.connect(
				_on_dialog_finished,
				CONNECT_ONE_SHOT
			)

		if Dialogic.timeline_exists(timeline_name):
			Dialogic.start(timeline_name)
		else:
			push_error("❌ Timeline '%s' tidak ditemukan!" % timeline_name)
			_on_dialog_finished()
	else:
		push_error("❌ Dialogic tidak ditemukan!")


# ==========================================================
# DIALOGIC SIGNAL
# ==========================================================
func _on_dialogic_signal(argument: String):
	print("📡 DIALOG SIGNAL:", argument)

	match argument:
		"go_to_pemukiman":
			teleport_player()


# ==========================================================
# TELEPORT PLAYER
# ==========================================================
func teleport_player():
	if player_ref == null:
		push_error("❌ Player reference tidak ditemukan!")
		return

	if spawn_point == null:
		push_error("❌ Spawn point tidak ditemukan!")
		return

	print("🚀 Teleport player ke pemukiman")
	player_ref.global_position = spawn_point.global_position
	emit_signal("spawner_pemukiman")


# ==========================================================
# DIALOG FINISHED
# ==========================================================
func _on_dialog_finished():
	print("✅ DIALOG FINISHED")

	if player_ref:
		player_ref.set_physics_process(true)

	dialog_started = false
