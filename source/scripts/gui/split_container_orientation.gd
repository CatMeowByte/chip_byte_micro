extends SplitContainer


func _on_resized() -> void:
	vertical = size.y >= size.x
