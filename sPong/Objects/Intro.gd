extends CanvasLayer

signal finish()

func _on_VideoPlayer_finished():
	emit_signal("finish")
	queue_free()
