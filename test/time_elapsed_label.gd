extends Label

var time_passed = 0

func _process(delta):
	time_passed += delta
	self.text = "Time Elapsed: %.2f" % time_passed
