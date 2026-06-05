extends Node

# ==========================================================
# SIGNALS
# ==========================================================
signal tutorial_done
signal enemy_died
signal game_started
signal spawn_enemy_tutorial
signal spawn_enemy_tree
signal diamonds_collected
signal tree_completed
signal player_died
signal show_elephant_marker
signal cutscene_finished

# 🔥 SIGNAL UNTUK FIGHT GAJAH
signal elephant_fight_started
signal elephant_fight_finished


# ==========================================================
# GAME STATE MEMORY
# ==========================================================
var after_cutscene: bool = false
var tutorial_completed: bool = false
var game_started_flag: bool = false
var elephant_defeated: bool = false  # Penanda bahwa gajah sudah dikalahkan


# ==========================================================
# HELPER FUNCTIONS
# ==========================================================

# Dipanggil saat cutscene selesai
func mark_cutscene_done():
	after_cutscene = true
	print("🎬 Cutscene selesai ditandai.")
	emit_signal("cutscene_finished")


# Dipanggil saat tutorial selesai
func mark_tutorial_done():
	tutorial_completed = true
	print("📘 Tutorial selesai.")


# Dipanggil saat game benar-benar dimulai
func mark_game_started():
	game_started_flag = true
	print("🎮 Game dimulai.")
	emit_signal("game_started")


# ==========================================================
# ELEPHANT FIGHT CONTROLLER
# ==========================================================

# Dipanggil saat fight dengan gajah dimulai
func start_elephant_fight():
	print("🐘 Fight gajah dimulai.")
	emit_signal("elephant_fight_started")


# Dipanggil saat gajah berhasil dikalahkan
func finish_elephant_fight():
	if not elephant_defeated:
		elephant_defeated = true
		print("✅ Gajah telah dikalahkan.")
		emit_signal("elephant_fight_finished")
