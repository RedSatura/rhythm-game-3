extends Label

func _ready():
	SignalHandler.connect("send_error", Callable(self, "display_error"))

func display_error(error):
	self.text += "ERROR: " + str(error) + "\n"
