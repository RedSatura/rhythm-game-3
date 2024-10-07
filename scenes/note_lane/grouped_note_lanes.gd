extends Node2D

@onready var note_lane_1: Node = $NoteLane1
@onready var note_lane_2: Node = $NoteLane2
@onready var note_lane_3: Node = $NoteLane3
@onready var note_lane_4: Node = $NoteLane4

@onready var ui: Node = $UI
@onready var lyric_label: Node = $UI/LyricLabel

@onready var image_displayer: Node = $UI/ImageDisplayer
@onready var video_player: Node = $UI/VideoPlayer

@onready var video_player_offset: Node = $UI/VideoPlayer/VideoPlayerOffset

var seconds_per_beat: float = 0 #Important for syncing tweens to the beat!

func _ready() -> void:
	SignalHandler.connect("spawn_note", Callable(self, "spawn_note_on_lane"))
	SignalHandler.connect("disable_lane", Callable(self, "disable_lane"))
	SignalHandler.connect("move_lane", Callable(self, "move_lane"))
	SignalHandler.connect("set_note_lane_setting_auto_mode", Callable(self, "set_note_lane_auto_mode"))
	SignalHandler.connect("get_song_seconds_per_beat", Callable(self, "set_seconds_per_beat"))
	SignalHandler.connect("update_lyric", Callable(self, "update_lyric"))
	SignalHandler.connect("song_started", Callable(self, "song_started"))
	SignalHandler.connect("song_ended", Callable(self, "song_ended"))
	$UI.theme = GlobalData.global_settings["theme"]
	video_player.stream = null
	if GlobalData.song_info["video_offset"] <= 0.05:
		video_player.play()
	else:
		video_player_offset.start(GlobalData.song_info["video_offset"])

func spawn_note_on_lane(lane_number: int) -> void:
	#man this solution is terrible but it works
	match lane_number:
		0:
			var random_number: int = RandomNumberGenerator.new().randi_range(1, 4)
			spawn_note_on_lane(random_number)
		1:
			note_lane_1.spawn_note()
		2:
			note_lane_2.spawn_note()
		3:
			note_lane_3.spawn_note()
		4:
			note_lane_4.spawn_note()
		_:
			pass

func disable_lane(lane_number: int, duration: int) -> void:
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
			
func set_note_lane_auto_mode(status: bool = false) -> void:
	note_lane_1.auto_mode = status
	note_lane_2.auto_mode = status
	note_lane_3.auto_mode = status
	note_lane_4.auto_mode = status

func move_lane(lane_number: int, movement_value: int = 0, duration: int = 1) -> void:
	match lane_number:
		1:
			note_lane_1.move_lane(movement_value, duration * seconds_per_beat)
		2:
			note_lane_2.move_lane(movement_value, duration * seconds_per_beat)
		3:
			note_lane_3.move_lane(movement_value, duration * seconds_per_beat)
		4:
			note_lane_4.move_lane(movement_value, duration * seconds_per_beat)
		_:
			pass

func set_seconds_per_beat(seconds: float) -> void:
	seconds_per_beat = seconds

func reset_lanes() -> void:
	note_lane_1.position.x = 64
	note_lane_2.position.x = 192
	note_lane_3.position.x = 320
	note_lane_4.position.x = 448
	video_player.stream = null

func update_lyric(text: String) -> void:
	lyric_label.text = text
	
func load_image() -> void:
	var image_path: String = GlobalData.song_info["image_src"]
	if FileAccess.file_exists(image_path):
		var image: Image = Image.load_from_file(GlobalData.song_info["image_src"])
		var texture: Texture = ImageTexture.create_from_image(image)
		image_displayer.texture = texture
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(image_displayer, "modulate", Color(1.0, 1.0, 1.0, 0.5), 2)
	else:
		SignalHandler.emit_signal("send_error", "Image does not exist.")
		return
	
func load_video() -> void:
	var video_path: String = GlobalData.song_info["video_src"]
	if FileAccess.file_exists(video_path):
		if video_path.get_extension() == "ogv":
			var ogv: VideoStreamTheora = VideoStreamTheora.new()
			ogv.set_file(video_path)
			video_player.stream = ogv
			image_displayer.visible = false
		else:
			SignalHandler.emit_signal("send_error", "Video format not supported, unable to play video!")
			return
	else:
		return

func song_started() -> void:
	load_image()
	load_video()
	if video_player.stream:
		if GlobalData.song_info["video_offset"] <= 0.05:
			video_player.play()
		else:
			video_player_offset.start(GlobalData.song_info["video_offset"])
	lyric_label.text = ""

func _on_video_player_offset_timeout() -> void:
	video_player.play()

func song_ended() -> void:
	video_player.stop()
	image_displayer.modulate = Color(1.0, 1.0, 1.0, 0.0)
