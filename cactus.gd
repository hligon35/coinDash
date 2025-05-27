extends Area2D

var screenSize = Vector2.ZERO

func onAreaEntered(area: Area2D) -> void:
	if area.is_in_group("coins") or is_in_group("powerups"):
		position = Vector2(randf_range(0, screenSize.x), randf_range(0, screenSize.y))
