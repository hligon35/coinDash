extends Area2D

signal pickup
signal hurt

@export var speed = 350
var velocity = Vector2.ZERO
var screenSize = Vector2(480, 720)
var touchPos = Vector2.ZERO
var isTouching = false
var joystickInput = Vector2.ZERO

func _ready():
	# Make sure input is processed
	set_process_input(true)

func _input(event):
	# Handle direct touch input for simpler touch control
	if event is InputEventScreenTouch:
		if event.pressed:
			touchPos = event.position
			isTouching = true
		else:
			isTouching = false
			velocity = Vector2.ZERO
	
	# Handle touch drag (moving finger)
	elif event is InputEventScreenDrag:
		touchPos = event.position

# Called by the touch control joystick
func set_joystick_input(direction):
	joystickInput = direction

func _process(delta):
	# Handle keyboard input
	var keyboardInput = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Priority: joystick input > direct touch > keyboard
	if joystickInput != Vector2.ZERO:
		velocity = joystickInput
	elif isTouching:
		# If using direct touch, calculate movement direction based on player position and touch position
		var direction = (touchPos - position).normalized()
		velocity = direction
	else:
		# Otherwise use keyboard input
		velocity = keyboardInput
	
	# Move the player
	position += velocity * speed * delta

	# Clamp position to stay within screen boundaries
	position.x = clamp(position.x, 0, screenSize.x)
	position.y = clamp(position.y, 0, screenSize.y)

	# Update animation based on movement
	if velocity.length() > 0:
		$AnimatedSprite2D.animation = "run"
	else:
		$AnimatedSprite2D.animation = "idle"

	# Flip sprite based on horizontal movement direction
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

func start():
	set_process(true)
	position = screenSize / 2
	$AnimatedSprite2D.animation = "idle"

func die():
	$AnimatedSprite2D.animation = "hurt"
	set_process(false)

func onAreaEntered(area: Area2D) -> void:
	if area.is_in_group("coins"):
		area.pickup()
		pickup.emit("coin")
	elif area.is_in_group("powerups"):
		area.pickup()
		pickup.emit("powerup")
	elif area.is_in_group("obstacles"):
		hurt.emit()
		die()
