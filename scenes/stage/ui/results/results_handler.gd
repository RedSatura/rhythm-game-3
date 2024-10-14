extends Control

@export var in_editor: bool = false
@export var lane_identifier: int = 1

@onready var visibility_timer: Node = $VisibilityTimer

@onready var rating_result_label: Node = $Rating/RatingPercentResult

#i suck at coding, i apologize to whoever needs to read this
#for player 1
var total_notes_1: int = 0
var perfect_1: int = 0
var good_1: int = 0
var miss_1: int = 0

#for player 2
var total_notes_2: int = 0
var perfect_2: int = 0
var good_2: int = 0
var miss_2: int = 0

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
	if lane_identifier == 1:
		$Perfect/PerfectResult.text = str(perfect_1)
		$Good/GoodResult.text = str(good_1)
		$Miss/MissResult.text = str(miss_1)
		var hit_rate: float = (float(perfect_1 + good_1) / total_notes_1) * 100 if total_notes_1 != 0 else 0.0
		$HitRate/HitRatePercentResult.text = "%3.2f" % hit_rate + '%' 
		$HitRate/HitRateIntegerResult.text = str(perfect_1 + good_1) + ' / ' + str(total_notes_1)
		var grade: float = set_grade()
		rating_result_label.text = "%3.2f" % grade + '%' 
	elif lane_identifier == 2:
		$Perfect/PerfectResult.text = str(perfect_2)
		$Good/GoodResult.text = str(good_2)
		$Miss/MissResult.text = str(miss_2)
		var hit_rate: float = (float(perfect_2 + good_2) / total_notes_2) * 100 if total_notes_2 != 0 else 0.0
		$HitRate/HitRatePercentResult.text = "%3.2f" % hit_rate + '%' 
		$HitRate/HitRateIntegerResult.text = str(perfect_2 + good_2) + ' / ' + str(total_notes_2)
		var grade: float = set_grade()
		rating_result_label.text = "%3.2f" % grade + '%' 
	
func process_note_hit(grade: String, source: int) -> void:
	#this is a fucking abomination, i am deeply sorry
	if source == 1:
		total_notes_1 += 1
		match grade:
			"PERFECT":
				perfect_1 += 1
			"GOOD":
				good_1 += 1
			"MISS":
				miss_1 += 1
			"EARLY":
				good_1 += 1
			"LATE":
				good_1 += 1
	elif source == 2:
		total_notes_2 += 1
		match grade:
			"PERFECT":
				perfect_2 += 1
			"GOOD":
				good_2 += 1
			"MISS":
				miss_2 += 1
			"EARLY":
				good_2 += 1
			"LATE":
				good_2 += 1

func set_grade() -> float:
	var grade: float = 0.0
	if lane_identifier == 1:
		grade = (((float(perfect_1) * 1.5) + good_1) / (total_notes_1 * 1.5)) * 100 if total_notes_1 != 0 else 0.0
	elif lane_identifier == 2:
		grade = (((float(perfect_2) * 1.5) + good_2) / (total_notes_2 * 1.5)) * 100 if total_notes_2 != 0 else 0.0
	return grade
