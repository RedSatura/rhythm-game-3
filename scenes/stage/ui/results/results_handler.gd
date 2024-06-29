extends Control

@onready var visibility_timer = $VisibilityTimer

var total_notes = 0
var perfect = 0
var good = 0
var miss = 0

func _ready():
	self.visible = false
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))
	SignalHandler.connect("note_hit", Callable(self, "process_note_hit"))
	
func process_song_end():
	visibility_timer.start()

func _on_visiblity_timer_timeout():
	show_results()

func show_results():
	self.visible = true
	$Perfect/PerfectResult.text = str(perfect)
	$Good/GoodResult.text = str(good)
	$Miss/MissResult.text = str(miss)
	var hit_rate = (float(perfect + good) / total_notes) * 100
	$HitRate/HitRatePercentResult.text = "%3.2f" % hit_rate + '%' 
	$HitRate/HitRateIntegerResult.text = str(perfect + good) + '/' + str(total_notes)
	
func process_note_hit(grade):
	total_notes += 1
	match grade:
		"PERFECT":
			perfect += 1
		"GOOD":
			good += 1
		"MISS":
			miss += 1
