extends SplitContainer
class_name SplitContainerDynamic

func _on_resized() -> void:
	vertical = size.y >= size.x
