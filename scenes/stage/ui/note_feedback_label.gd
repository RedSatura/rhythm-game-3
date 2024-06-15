extends Label

var combo = 0

func _ready():
	self.visible = false
	SignalHandler.connect("note_hit", Callable(self, "process_note_hit"))
	
func _process(delta):
	pass
	
func process_note_hit(grade):
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

func update_label(grade):
	self.text = str(grade) + "!\nCombo x%d" % [combo]
	self.visible = true

func _on_visibility_timer_timeout():
	self.visible = false
