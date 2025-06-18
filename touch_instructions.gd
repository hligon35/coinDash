extends Label

# How long to show the instructions
@export var display_time = 7.0

func _ready():
	# Only show the instructions on touch devices
	visible = DisplayServer.is_touchscreen_available()
	if visible:
		# Auto-hide after some seconds
		var timer = Timer.new()
		timer.wait_time = display_time
		timer.one_shot = true
		timer.timeout.connect(func(): visible = false)
		add_child(timer)
		timer.start()
