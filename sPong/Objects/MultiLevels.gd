extends Node

export(PackedScene) var viewport_scene
export(PackedScene) var game_level_scene
export(int) var level_count = 2

var levels = []


""" PUBLIC """

func get_level_count() -> int:
	return levels.size()


func get_level(i) -> GameLevel:
	return levels[i].get_child(0)


func get_level_viewport(i) -> Viewport:
	return levels[i]


""" PRIVATE """


func add_game_level():
	var v = viewport_scene.instance()
	var g = game_level_scene.instance()

	add_child(v)
	v.add_child(g)

	levels.push_back(v)


""" NOTIFICATIONS """


func _ready():
	for i in range(level_count):
		add_game_level()
