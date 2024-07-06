extends Control

@onready var visibility_timer: Node = $VisibilityTimer

var total_notes: int = 0
var perfect: int = 0
var good: int = 0
var miss: int = 0

func _ready() -> void:
	self.visible = false
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))
	SignalHandler.connect("note_hit", Callable(self, "process_note_hit"))
	
func process_song_end() -> void:
	visibility_timer.start()

func _on_visiblity_timer_timeout() -> void:
	show_results()

func show_results() -> void:
	self.visible = true
	$Perfect/PerfectResult.text = str(perfect)
	$Good/GoodResult.text = str(good)
	$Miss/MissResult.text = str(miss)
	var hit_rate: float = (float(perfect + good) / total_notes) * 100
	$HitRate/HitRatePercentResult.text = "%3.2f" % hit_rate + '%' 
	$HitRate/HitRateIntegerResult.text = str(perfect + good) + '/' + str(total_notes)
	
func process_note_hit(grade: String) -> void:
	total_notes += 1
	match grade:
		"PERFECT":
			perfect += 1
		"GOOD":
			good += 1
		"MISS":
			miss += 1
