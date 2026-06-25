extends Node2D

enum GameState {
	TUTORIAL,
	STORY,
	PLAYING,
	TREE_QUEST
}

var current_state = GameState.TUTORIAL

@export var tutorial_timeline: String = "tutorial"
@export var after_tutorial_timeline: String = "after_tutorial"
@export var after_cutscene_timeline: String = "pemukiman_open"
@export var tree_after_timeline: String = "tree_after_quest"

#COUNTER TUTORIAL
@export var required_tutorial_done: int = 2
var tutorial_done_count: int = 0

#STATE
var game_started := false

# REFERENSI NODE AUDIO (anak dari game manager)
@onready var sfx_shoot = $SFX/Shoot
@onready var sfx_hurt = $SFX/Hurt
@onready var sfx_energy = $SFX/Energy
@onready var sfx_walk = $SFX/Walk


func _ready():
	# Force play BGM di bus khusus agar tidak bentrok
	if has_node("/root/Bgm"):
		var bgm = get_node("/root/Bgm")
		bgm.volume_db = 0.0
		bgm.bus = "GameBGM"
		bgm.stop()
		bgm.play()
		print("🎵 BGM berhasil dinyalakan di Bus Khusus!")

	# Hubungkan ke EventBus
	if EventBus:
		connect_signal_safe(EventBus.tutorial_done, _on_tutorial_done)
		connect_signal_safe(EventBus.tree_completed, _on_tree_completed)
		connect_signal_safe(EventBus.spawn_enemy_tutorial, _on_spawn_enemy_tutorial)
		connect_signal_safe(EventBus.spawn_enemy_tree, _on_spawn_enemy_tree)
		connect_signal_safe(EventBus.player_died, _on_player_died)
		connect_signal_safe(EventBus.cutscene_finished, _on_cutscene_finished)

	if Dialogic:
		connect_signal_safe(Dialogic.signal_event, _on_dialogic_signal)

	var scene = get_tree().current_scene
	if scene and scene.scene_file_path.ends_with("main.tscn"):
		if EventBus.after_cutscene:
			call_deferred("start_after_cutscene_dialog")
		else:
			call_deferred("start_tutorial")


func connect_signal_safe(signal_ref: Signal, callable: Callable):
	if signal_ref:
		if signal_ref.is_connected(callable):
			signal_ref.disconnect(callable)
		signal_ref.connect(callable)


func start_tutorial():
	current_state = GameState.TUTORIAL
	if Dialogic:
		Dialogic.start(tutorial_timeline)


func _on_tutorial_done():
	tutorial_done_count += 1
	if tutorial_done_count >= required_tutorial_done:
		if EventBus:
			EventBus.mark_tutorial_done()
		start_after_tutorial_dialog()


func start_after_tutorial_dialog():
	if current_state != GameState.TUTORIAL:
		return
	current_state = GameState.STORY
	if Dialogic:
		if Dialogic.has_signal("timeline_ended"):
			if not Dialogic.timeline_ended.is_connected(_on_after_timeline_finished):
				Dialogic.timeline_ended.connect(_on_after_timeline_finished, CONNECT_ONE_SHOT)
		Dialogic.start(after_tutorial_timeline)
	else:
		start_game()


func _on_after_timeline_finished():
		start_game()


func _on_cutscene_finished():
	EventBus.after_cutscene = true


func start_after_cutscene_dialog():
	EventBus.after_cutscene = false
	current_state = GameState.STORY
	if Dialogic:
		if Dialogic.has_signal("timeline_ended"):
			if not Dialogic.timeline_ended.is_connected(_on_after_cutscene_dialog_finished):
				Dialogic.timeline_ended.connect(_on_after_cutscene_dialog_finished, CONNECT_ONE_SHOT)
		Dialogic.start(after_cutscene_timeline)
	else:
		start_game()


func _on_after_cutscene_dialog_finished():
	start_game()


func start_game():
	if game_started:
		return
	game_started = true
	current_state = GameState.PLAYING
	if EventBus:
		EventBus.mark_game_started()
		EventBus.emit_signal("game_started")


func _on_tree_completed():
	current_state = GameState.TREE_QUEST
	start_tree_story()


func start_tree_story():
	if Dialogic:
		Dialogic.start(tree_after_timeline)


func start_tree_quest():
	current_state = GameState.TREE_QUEST
	if Dialogic:
		Dialogic.start("tree_intro")


func _on_spawn_enemy_tutorial():
	pass


func _on_spawn_enemy_tree():
	pass


func _on_player_died():
	play_sfx_hurt()
	match current_state:
		GameState.TUTORIAL:
			if get_tree(): get_tree().change_scene_to_file("res://scenes/cutscene/gameover.tscn")
		GameState.TREE_QUEST, GameState.PLAYING:
			if get_tree(): get_tree().change_scene_to_file("res://scenes/cutscene/rottenTomato.tscn")


func _on_dialogic_signal(argument: Variant):
	var sig_name = argument
	if typeof(argument) == TYPE_DICTIONARY and argument.has("argument"):
		sig_name = argument["argument"]
	if sig_name == "start_pemukiman_mission":
		start_tree_quest()


# FUNGSI UTAMA TOMBOL SFX (dipanggil oleh player)
func play_sfx_shoot():
	if sfx_shoot: sfx_shoot.play()

func play_sfx_hurt():
	if sfx_hurt: sfx_hurt.play()

func play_sfx_energy():
	if sfx_energy: sfx_energy.play()

func play_sfx_walk(is_moving: bool):
	if sfx_walk:
		if is_moving and not sfx_walk.playing:
			sfx_walk.play()
		elif not is_moving and sfx_walk.playing:
			sfx_walk.stop()
