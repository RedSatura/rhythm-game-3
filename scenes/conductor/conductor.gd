extends AudioStreamPlayer

##The song's bpm.
@export var bpm: int = 100
##The song's beat mode. 1 for quarter notes, 2 for eighth notes, and so on.
##You can use 0.5 for half notes and 0.25 for whole notes.
@export var beat_mode: float = 1.0
##Controls how many beats in a measure.
@export var beats_in_measure: int = 4
##COntrols on what beat in the measure the song starts from.
@export var starting_beat_in_measure: int = 1

var song_position: float = 0.0
var song_position_in_beats: int = 0
var seconds_per_beat: float = 60.0 / bpm
var last_reported_beat: int = 0

@export var song_beat_delay: int = 0

var current_beat_in_measure: int = 1

##Audio offset in milliseconds. Must range from 0 to 1500. 
##Does not work, so don't bother. 
##Just add a delay to the audio file itself.
@export var audio_offset: float = 0

#Determining how close to the beat an event is
var closest_beat: int = 0
var time_off_beat: float = 0.0

func _ready() -> void:
	seconds_per_beat = 60.0 / (bpm * beat_mode)
	current_beat_in_measure = starting_beat_in_measure
	var effect: AudioEffect = AudioServer.get_bus_effect(1, 0)
	if effect:
		effect.set_dry(0)
		effect.set_tap1_active(true)
		if audio_offset <= 1.50:
			effect.set_tap1_delay_ms(audio_offset)
		effect.set_tap1_level_db(0)
		effect.set_tap1_pan(0)
		effect.set_tap2_active(false)

func _physics_process(_delta: float) -> void:
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / seconds_per_beat)) + song_beat_delay
		SignalHandler.emit_signal("get_song_position", song_position)
		SignalHandler.emit_signal("get_song_offset", song_position)
		report_beat()
	else:
		pass
		
func report_beat() -> void:
	if last_reported_beat < song_position_in_beats:
		last_reported_beat = song_position_in_beats
		if current_beat_in_measure > beats_in_measure:
			current_beat_in_measure = 1
			SignalHandler.emit_signal("measure_occured")
		SignalHandler.emit_signal("beat_occured", song_position_in_beats)
		current_beat_in_measure += 1
		
func play_from_beat() -> void:
	pass
	
func get_closest_beat(nth: int) -> Vector2:
	closest_beat = int(round((song_position / seconds_per_beat) / nth) * nth) 
	time_off_beat = abs(closest_beat * seconds_per_beat - song_position)
	return Vector2(closest_beat, time_off_beat)

func play_song() -> void:
	seconds_per_beat = 60.0 / (bpm * beat_mode)
	song_position = 0.0
	song_position_in_beats = 0
	last_reported_beat = 0
	volume_db = 0
	
	if stream:
		#send out relevant song data
		SignalHandler.emit_signal("get_song_length", stream.get_length())
		play()
	else:
		SignalHandler.emit_signal("send_error", "No audio stream found!")
