extends Label

@export var in_editor: bool = false
@export var lane_identifier: int = 1

var combo_1: int = 0
var combo_2: int = 0

func _ready() -> void:
	self.visible = false
	SignalHandler.connect("note_hit", Callable(self, "process_note_hit"))
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))
	
func _process(_delta: float) -> void:
	pass
	
#this is an absolute mess but it kinda works somehow
func process_note_hit(grade: String, source: int) -> void:
	if source == 1 && lane_identifier == 1:
		match grade:
			"PERFECT":
				combo_1 += 1
				update_label("Perfect!")
			"GOOD":
				combo_1 += 1
				update_label("Good")
			"MISS":
				combo_1 = 0
				update_label("Miss")
			"EARLY":
				combo_1 += 1
				update_label("Good (Early)")
			"LATE":
				combo_1 += 1
				update_label("Good (Late)")
	elif source == 2 && lane_identifier == 2:
		match grade:
			"PERFECT":
				combo_2 += 1
				update_label("Perfect!")
			"GOOD":
				combo_2 += 1
				update_label("Good")
			"MISS":
				combo_2 = 0
				update_label("Miss")
			"EARLY":
				combo_2 += 1
				update_label("Good (Early)")
			"LATE":
				combo_2 += 1
				update_label("Good (Late)")

func update_label(message: String) -> void:
	if !in_editor:
		if lane_identifier == 1:
			self.text = str(message) + "\nCombo x%d" % [combo_1]
			self.visible = true
			$VisibilityTimer.start()
		elif lane_identifier == 2:
			self.text = str(message) + "\nCombo x%d" % [combo_2]
			self.visible = true
			$VisibilityTimer.start()

func _on_visibility_timer_timeout() -> void:
	self.visible = false

func process_song_end() -> void:
	pass
