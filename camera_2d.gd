extends Camera2D

var pixel_size := 1.0

func _process(delta):
	global_position = global_position.round()
