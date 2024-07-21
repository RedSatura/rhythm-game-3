extends ProgressBar

func _ready() -> void:
	SignalHandler.connect("get_song_length", Callable(self, "process_song_length"))
	SignalHandler.connect("get_song_position", Callable(self, "process_song_position"))
	self.value = 0

func process_song_length(length: float) -> void:
	self.max_value = snapped(length, 0.01)

func process_song_position(current_pos: float) -> void:
	self.value = current_pos
