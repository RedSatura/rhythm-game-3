extends Label

func _process(delta: float) -> void:
	self.text = "FPS: " + str(Engine.get_frames_per_second())
