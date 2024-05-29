extends Node2D

@onready var note_lane_1 = $NoteLane1
@onready var note_lane_2 = $NoteLane2
@onready var note_lane_3 = $NoteLane3
@onready var note_lane_4 = $NoteLane4

func spawn_note_on_lane(lane_number):
	#man this solution is terrible but it works
	match lane_number:
		1:
			note_lane_1.spawn_note()
		2:
			note_lane_2.spawn_note()
		3:
			note_lane_3.spawn_note()
		4:
			note_lane_4.spawn_note()
		"r":
			var random_number = RandomNumberGenerator.new().randi_range(1, 4)
			spawn_note_on_lane(random_number)
		_:
			pass

func disable_lane(lane_number, duration):
	#this is also terrible but i'll improve it eventually
	match lane_number:
		1:
			note_lane_1.disable_lane(duration)
		2:
			note_lane_2.disable_lane(duration)
		3:
			note_lane_3.disable_lane(duration)
		4:
			note_lane_4.disable_lane(duration)
		_:
			pass
			
func set_note_lane_auto_mode(status = false):
	note_lane_1.auto_mode = status
	note_lane_2.auto_mode = status
	note_lane_3.auto_mode = status
	note_lane_4.auto_mode = status
