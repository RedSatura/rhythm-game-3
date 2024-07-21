extends Label

var measure: int = 0

func _ready() -> void:
	SignalHandler.connect("beat_occured", Callable(self, "update_text"))
	SignalHandler.connect("measure_occured", Callable(self, "measure_occured"))
	
func update_text(beat: int) -> void:
	self.text = "Current Beat: %d\nMeasures Occured: %d" % [beat, measure]
	
func measure_occured() -> void:
	measure += 1
