extends Label

var time_passed: float = 0
var song_offset: float = 0

func _ready() -> void:
	SignalHandler.connect("get_song_offset", Callable(self, "process_song_offset"))

func _process(delta: float) -> void:
	time_passed += delta
	self.text = "Time Elapsed: %.2f\nCurrent Position: %.2f" % [time_passed, song_offset]
	
func process_song_offset(offset: float) -> void:
	song_offset = offset
