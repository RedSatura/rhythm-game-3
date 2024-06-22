extends Control

@onready var visibility_timer = $VisibilityTimer

var total_notes = 0
var perfect = 0
var good = 0
var miss = 0

func _ready():
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))
	SignalHandler.connect("note_hit", Callable(self, "process_note_hit"))
	
func process_song_end():
	visibility_timer.start()

func _on_visiblity_timer_timeout():
	show_results()

func show_results():
	self.visible = true
	
func process_note_hit(grade):
	total_notes += 1
	match grade:
		"PERFECT":
			perfect += 1
		"GOOD":
			good += 1
		"MISS":
			miss += 1
