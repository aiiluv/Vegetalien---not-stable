extends CharacterBody2D

@onready var target = $"../Player"
var speed = 50

func _physics_process(delta):
	if target == null:
		#print("Target null!")
		return
	
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	
	move_and_slide()
