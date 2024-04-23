extends Label

var measure = 0

func _ready():
	SignalHandler.connect("beat_occured", Callable(self, "update_text"))
	SignalHandler.connect("measure_occured", Callable(self, "measure_occured"))
	
func update_text(beat):
	self.text = "Current Beat: %d\nMeasures Occured: %d" % [beat, measure]
	
func measure_occured():
	measure += 1
