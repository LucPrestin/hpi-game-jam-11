extends Node

func get_level():
	return get_tree().get_root().find_node("level", true, false)

enum Tile { GRAS, DIRT }
