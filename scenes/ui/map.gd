extends Control

@onready var label: Label = $Label
@onready var map_sprite: Sprite2D = $Sprite2D

var map_open := false
var map_unlocked := false  # 🔥 KUNCI

func _ready():
	label.visible = false      # ❌ awalnya ga muncul
	map_sprite.visible = false

	# 🔥 denger signal dari dialog carrot
	if Dialogic:
		Dialogic.signal_event.connect(_on_dialog_signal)

func _process(delta):
	if not map_unlocked:
		return  # ❌ belum boleh buka map

	if Input.is_action_just_pressed("open_map"):
		toggle_map()

# ==========================================================
# 🔥 UNLOCK SETELAH CARROT
# ==========================================================
func _on_dialog_signal(arg: String):
	if arg == "follow_carrot":
		print("🗺️ Map unlocked!")
		map_unlocked = true
		label.visible = true  # 🔥 munculin "Press M"

# ==========================================================
# TOGGLE MAP
# ==========================================================
func toggle_map():
	map_open = !map_open

	if map_open:
		map_sprite.visible = true
		label.visible = false
	else:
		map_sprite.visible = false
		label.visible = true
