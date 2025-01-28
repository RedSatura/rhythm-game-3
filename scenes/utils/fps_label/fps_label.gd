extends Label

func _ready() -> void:
	SignalHandler.connect("beat_occured", Callable(self, "beat_occured"))

func beat_occured(_pos: int) -> void:
	self.text = "FPS: " + str(Engine.get_frames_per_second())
