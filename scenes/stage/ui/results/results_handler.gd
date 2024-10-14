extends Control

@export var in_editor: bool = false

@onready var visibility_timer: Node = $VisibilityTimer

@onready var rating_result_label: Node = $Rating/RatingPercentResult

var total_notes: int = 0
var perfect: int = 0
var good: int = 0
var miss: int = 0

func _ready() -> void:
	self.visible = false
	SignalHandler.connect("song_ended", Callable(self, "process_song_end"))
	SignalHandler.connect("note_hit", Callable(self, "process_note_hit"))
	
func process_song_end() -> void:
	if !in_editor:
		visibility_timer.start()

func _on_visiblity_timer_timeout() -> void:
	show_results()

func show_results() -> void:
	self.visible = true
	$Perfect/PerfectResult.text = str(perfect)
	$Good/GoodResult.text = str(good)
	$Miss/MissResult.text = str(miss)
	var hit_rate: float = (float(perfect + good) / total_notes) * 100 if total_notes != 0 else 0.0
	$HitRate/HitRatePercentResult.text = "%3.2f" % hit_rate + '%' 
	$HitRate/HitRateIntegerResult.text = str(perfect + good) + ' / ' + str(total_notes)
	var grade: float = set_grade()
	rating_result_label.text = "%3.2f" % grade + '%' 
	
func process_note_hit(grade: String) -> void:
	total_notes += 1
	match grade:
		"PERFECT":
			perfect += 1
		"GOOD":
			good += 1
		"MISS":
			miss += 1
		"EARLY":
			good += 1
		"LATE":
			good += 1

func set_grade() -> float:
	var grade: float = (((float(perfect) * 1.5) + good) / (total_notes * 1.5)) * 100 if total_notes != 0 else 0.0
	return grade
