extends Node

func get_level():
	return get_tree().get_root().find_node("level", true, false)
	
func get_game():
	return get_tree().get_root().find_node("game", true, false)

enum Tile { GRAS, DIRT }
enum PlantType { TREE, FLOWER }

const PIXEL_PER_TILE = 16
