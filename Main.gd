var tutorial_step = 0

func run_tutorial():
	match tutorial_step:
		0:
			show_text("Gerak pake WASD")
			if player.velocity.length() > 0:
				tutorial_step = 1

		1:
			show_text("Klik untuk shoot")
			if Input.is_action_just_pressed("shoot"):
				tutorial_step = 2

		2:
			show_text("Ambil energy")
			if player.current_stamina > 0:
				tutorial_step = 3

		3:
			show_text("Mantap! 🔥")
			await get_tree().create_timer(2).timeout
			current_state = GameState.STORY
			
func show_text ():
	
