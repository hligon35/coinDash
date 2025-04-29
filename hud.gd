extends CanvasLayer
signal startGame

func updateScore(value):
	$MarginContainer/Score.text = str(value)

func updateTimer(value):
	$MarginContainer/Time.text = str(value)

func updateLevel(value):
	$MarginContainer/Level.text = "Level: " + str(value)

func showMessage(text):
	$Message.text = text
	$Message.show()
	$Timer.start()

func onTimerTimeout() -> void:
	$Message.hide()

func onStartButtonPressed() -> void:
	$StartButton.hide()
	$Message.hide()
	startGame.emit()

func showGameOver():
	showMessage("Game Over!!!")
	await $Timer.timeout
	$StartButton.show()
	$Message.text = "Coin Dash!"
	$Message.show()
