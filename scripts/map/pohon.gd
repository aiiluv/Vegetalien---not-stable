extends Node2D

@export var required_diamonds := 4

var player_in_range := false
var diamonds := 0
var first_interaction_done := false
var quest_finished := false
var ready_to_finish := false # 🔥 NEW

@onready var area: Area2D = $Area2D
@onready var label: Label = $Label

func _ready():
	label.visible = false

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	if EventBus:
		EventBus.diamonds_collected.connect(_on_diamond_collected)

# ==========================================================
# DETEKSI PLAYER
# ==========================================================
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

		# 🔥 UBAH TEXT SESUAI STATE
		if ready_to_finish:
			label.text = "Press E (Selesaikan)"
		else:
			label.text = "Press E"

		label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		label.visible = false

# ==========================================================
# INPUT
# ==========================================================
func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()

# ==========================================================
# INTERACT
# ==========================================================
func interact():
	# 🔹 INTERAKSI AWAL
	if not first_interaction_done:
		first_interaction_done = true
		label.visible = false
		start_dialog()
		return

	# 🔹 FINAL CUTSCENE (SETELAH BALIK)
	if ready_to_finish and not quest_finished:
		quest_finished = true
		label.visible = false

		print("Trigger CUTSCENE FINAL")

		play_cutscene()
		EventBus.emit_signal("tree_completed")
		return

	print("Belum bisa interaksi")

# ==========================================================
# DIALOG AWAL
# ==========================================================
func start_dialog():
	if Dialogic:
		Dialogic.start("tree_dialog")

		if Dialogic.has_signal("timeline_ended"):
			Dialogic.timeline_ended.connect(_on_dialog_finished, CONNECT_ONE_SHOT)

func _on_dialog_finished():
	EventBus.emit_signal("spawn_enemy_tree")

# ==========================================================
# DIAMOND LOGIC
# ==========================================================
func _on_diamond_collected():
	diamonds += 1
	print("Diamond:", diamonds, "/", required_diamonds)

	if diamonds >= required_diamonds and not ready_to_finish:
		ready_to_finish = true

		print("Diamond cukup → balik ke pohon")

		# 🔥 Dialog hint (opsional)
		if Dialogic:
			Dialogic.start("quest_pemukiman_selesai")

# ==========================================================
# CUTSCENE FINAL
# ==========================================================
func play_cutscene():
	get_tree().change_scene_to_file("res://scenes/cutscene/backstory.tscn") #ganti ke happy end nanti
