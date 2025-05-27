extends Node

@export var coinScene: PackedScene
@export var playtime = 30
@export var powerupScene: PackedScene
@export var cactusScene: PackedScene

var level = 1
var score = 0
var timeLeft = 0
var screenSize: Vector2 = Vector2.ZERO
var cactusCount = 0
var playing = false

func _ready():
	screenSize = get_viewport().get_visible_rect().size
	$Player.screenSize = screenSize
	$Player.hide()

func newGame():
	playing = true
	level = 1
	score = 0
	timeLeft = playtime
	cactusCount = 0
	$Player.start()
	$Player.show()
	$Player.position = screenSize / 2
	$GameTimer.start()
	$HUD.updateScore(score)
	$HUD.updateTimer(timeLeft)
	$HUD.updateLevel(level)

	# Remove leftover cacti
	get_tree().call_group("obstacles", "queue_free")

	# Start with 2 cacti
	spawnCactus()
	spawnCactus()
	spawnCoins()

func spawnCoins():
	for i in range(level + 4):
		var coin = coinScene.instantiate()
		add_child(coin)
		coin.screenSize = screenSize

		# Ensure the coin does not collide with cacti or the player
		var position = getRandomPosition()
		while isPositionOverlappingWithCactus(position) or isPositionOverlappingWithPlayer(position):
			position = getRandomPosition()
		coin.position = position

	# Spawn powerup every 3rd level
	if level % 3 == 0:
		var powerup = powerupScene.instantiate()
		add_child(powerup)
		powerup.screenSize = screenSize
		var position = getRandomPosition()
		while isPositionOverlappingWithCactus(position):
			position = getRandomPosition()
		powerup.position = position

	# Spawn additional cactus every 3 levels
	if level % 3 == 0:
		spawnCactus()

	$LevelSound.play()

func spawnCactus():
	var cactus = cactusScene.instantiate()
	add_child(cactus)
	cactus.add_to_group("obstacles")

	# Ensure the cactus does not collide with coins or the player
	var position = getRandomPosition()
	while isPositionOverlappingWithCoins(position) or isPositionOverlappingWithPlayer(position) or isPositionOverlappingWithCactus(position):
		position = getRandomPosition()
	cactus.position = position

func getRandomPosition() -> Vector2:
	return Vector2(randf_range(0, screenSize.x), randf_range(0, screenSize.y))

func isPositionOverlappingWithPlayer(position: Vector2) -> bool:
	return $Player.global_position.distance_to(position) < 100

func isPositionOverlappingWithCactus(position: Vector2) -> bool:
	for cactus in get_tree().get_nodes_in_group("obstacles"):
		if cactus.global_position.distance_to(position) < 100:
			return true
	return false

func isPositionOverlappingWithCoins(position: Vector2) -> bool:
	for coin in get_tree().get_nodes_in_group("coins"):
		if coin.global_position.distance_to(position) < 100:
			return true
	return false

func _process(_delta):
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		timeLeft += 5
		$HUD.updateLevel(level)
		spawnCoins()
		#onPowerupTimerTimeout()

func onGameTimerTimeout() -> void:
	timeLeft -= 1
	$HUD.updateTimer(timeLeft)
	if timeLeft <= 0:
		gameOver()

func onPlayerHurt():
	gameOver()

func onPlayerPickup(type):
	match type:
		"coin":
			$CoinSound.play()
			score += 1
			$HUD.updateScore(score)
		"powerup":
			$PowerupSound.play()
			score += 3
			timeLeft += 5
			$HUD.updateScore(score)
			$HUD.updateTimer(timeLeft)

func gameOver():
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free")
	get_tree().call_group("obstacles", "queue_free")
	cactusCount = 0
	$HUD.showGameOver()
	$Player.die()
	$EndSound.play()

func onHudStartGame() -> void:
	newGame()

func onPowerupTimerTimeout() -> void:
	var powerup = powerupScene.instantiate()
	add_child(powerup)
	powerup.screenSize = screenSize
	
