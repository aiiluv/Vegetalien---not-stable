extends CharacterBody2D

@export var texture: Texture2D

@onready var sprite = $Sprite2D

func _ready():
	if texture:
		sprite.texture = texture
