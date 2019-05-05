extends Node

export var intro_scene : PackedScene
export var skip_intro := false


func _ready():
	if skip_intro:
		intro_finis()
	else:
		var intro = intro_scene.instance()
		add_child(intro)
		intro.connect("finish", self, "intro_finis")


func intro_finis():
	get_tree().change_scene("res://GameLeve.tscn")
