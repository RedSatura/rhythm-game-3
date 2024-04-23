extends Label

var time_passed = 0
var song_offset = 0

func _ready():
	SignalHandler.connect("get_song_offset", Callable(self, "process_song_offset"))

func _process(delta):
	time_passed += delta
	self.text = "Time Elapsed: %.2f\nCurrent Position: %.2f" % [time_passed, song_offset]
	
func process_song_offset(offset):
	song_offset = offset
