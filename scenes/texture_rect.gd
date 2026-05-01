extends TextureRect

@onready var camera = get_viewport().get_camera_2d()

func _process(delta):
	position = camera.global_position * 0.9
