extends Control

@onready var image_displayer: Node = $ImageDisplayer
@onready var video_player: Node = $VideoPlayer

@onready var video_player_offset: Node = $VideoPlayer/VideoPlayerOffset

func _ready() -> void:
	SignalHandler.connect("song_started", Callable(self, "song_started"))
	SignalHandler.connect("song_ended", Callable(self, "song_ended"))
	
	self.theme = GlobalData.global_settings["theme"]
	
	video_player.stream = null
	if GlobalData.song_info["video_offset"] <= 0.05:
		video_player.play()
	else:
		video_player_offset.start(GlobalData.song_info["video_offset"])

func load_image() -> void:
	var image_path: String = GlobalData.song_info["image_src"]
	if FileAccess.file_exists(image_path):
		var image: Image = Image.load_from_file(GlobalData.song_info["image_src"])
		var texture: Texture = ImageTexture.create_from_image(image)
		image_displayer.texture = texture
		image_displayer.visible = true
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(image_displayer, "modulate", Color(1.0, 1.0, 1.0, 0.5), 2)
	else:
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
	video_player.stream = null
	
	load_image()
	load_video()
	
	if video_player.stream:
		if GlobalData.song_info["video_offset"] <= 0.05:
			video_player.play()
		else:
			video_player_offset.start(GlobalData.song_info["video_offset"])
			
func song_ended() -> void:
	video_player.stop()
	image_displayer.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _on_video_player_offset_timeout() -> void:
	video_player.play()
