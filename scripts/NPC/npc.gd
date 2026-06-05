extends CharacterBody2D

var player_near = false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	$Label.visible = false # awalnya mati

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		start_dialog()

func _on_body_entered(body):
	if body.name == "Player":
		player_near = true
		$Label.visible = true   # 👈 MUNCUL

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false
		$Label.visible = false  # 👈 HILANG

func start_dialog():
	Dialogic.start("mashdoom")
