extends Area2D

var screenSize = Vector2.ZERO

func pickup():
	$CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", scale * 3, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()

func _ready():
	$Timer.start(randf_range(2, 5))

func onTimerTimeout() -> void:
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play()

func onAreaEntered(area: Area2D) -> void:
	if area.is_in_group("obstacle"):
		position = Vector2(randf_range(0, screenSize.x), randf_range(0, screenSize.y))
