extends Label

var combo: int = 0

func _ready() -> void:
	self.visible = false
	SignalHandler.connect("note_hit", Callable(self, "process_note_hit"))
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))
	
func _process(_delta: float) -> void:
	pass
	
func process_note_hit(grade: String) -> void:
	match grade:
		"PERFECT":
			combo += 1
			update_label("PERFECT")
		"GOOD":
			combo += 1
			update_label("GOOD")
		"MISS":
			combo = 0
			update_label("MISS")

func update_label(grade: String) -> void:
	self.text = str(grade) + "!\nCombo x%d" % [combo]
	self.visible = true
	$VisibilityTimer.start()

func _on_visibility_timer_timeout() -> void:
	self.visible = false

func process_song_end() -> void:
	pass
