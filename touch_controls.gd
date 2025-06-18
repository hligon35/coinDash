extends CanvasLayer

signal joystick_input(direction)

var joystick_active = false
var joystick_position = Vector2.ZERO
var joystick_output = Vector2.ZERO
var touch_index = -1

# Radius of the outer joystick background
@export var joystick_radius = 100
# Scale of the inner circle relative to the outer
@export var inner_radius_ratio = 0.4

# Reference to drawn circles
var outer_circle: ColorRect
var inner_circle: ColorRect

func _ready():
	# Set process input to catch touch events
	set_process_input(true)
	
	# Check if device has touch screen
	visible = DisplayServer.is_touchscreen_available()
	
	# Create the joystick visuals
	outer_circle = ColorRect.new()
	outer_circle.color = Color(0.5, 0.5, 0.5, 0.5)
	outer_circle.size = Vector2(joystick_radius * 2, joystick_radius * 2)
	outer_circle.visible = false
	add_child(outer_circle)
	
	inner_circle = ColorRect.new()
	inner_circle.color = Color(0.8, 0.8, 0.8, 0.8)
	inner_circle.size = Vector2(joystick_radius * 2 * inner_radius_ratio, joystick_radius * 2 * inner_radius_ratio)
	inner_circle.visible = false
	add_child(inner_circle)

func update_joystick_visuals():
	if joystick_active:
		outer_circle.visible = true
		inner_circle.visible = true
		
		# Position the outer circle
		outer_circle.position = joystick_position - Vector2(joystick_radius, joystick_radius)
		
		# Position the inner circle (joystick)
		var inner_pos = joystick_position + joystick_output * joystick_radius
		inner_circle.position = inner_pos - Vector2(inner_circle.size.x / 2, inner_circle.size.y / 2)
	else:
		outer_circle.visible = false
		inner_circle.visible = false

func _input(event):
	if not DisplayServer.is_touchscreen_available():
		return
		
	if event is InputEventScreenTouch:
		if event.pressed:
			# Start joystick
			if touch_index == -1:
				touch_index = event.index
				joystick_active = true
				joystick_position = event.position
				joystick_output = Vector2.ZERO
				update_joystick_visuals()
		elif event.index == touch_index:
			# End joystick
			touch_index = -1
			joystick_active = false
			joystick_output = Vector2.ZERO
			joystick_input.emit(Vector2.ZERO)
			update_joystick_visuals()
			
	elif event is InputEventScreenDrag and event.index == touch_index:
		# Update joystick position
		var delta_position = event.position - joystick_position
		
		if delta_position.length() > joystick_radius:
			joystick_output = delta_position.normalized()
		else:
			joystick_output = delta_position / joystick_radius
			
		joystick_input.emit(joystick_output)
		update_joystick_visuals()

func is_active():
	return joystick_active
