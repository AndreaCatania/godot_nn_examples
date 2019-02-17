extends Control

export(NodePath) var level_path


func get_button(row: int, column: int):
	return get_node("Button" + String(row) + String(column))


func get_button_by_id(id: int):
	return get_child(id)


func on_click(button, row, column):
	if button.is_free:
		get_node(level_path).player_put_mark(row, column)


func _ready():
	var row := 0
	var col := 0
	for c in get_children():
		c.connect("pressed", self, "on_click", [c, row, col])
		col = col + 1
		if col >= 3:
			col = 0
			row = row + 1
