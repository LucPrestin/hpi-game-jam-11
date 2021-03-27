extends Node

func get_level():
	return get_tree().get_root().find_node("level", true, false)
	
func get_game():
	return get_tree().get_root().find_node("game", true, false)

func get_players():
	var all_nodes = get_tree().get_root().find_node("level_switch", true, false).get_children()
	return _filter(funcref(self, "_is_player"), all_nodes)

func _is_player(node: Node):
	return node is Player

func _filter(function: FuncRef, array: Array) -> Array:
	var output = []
	for element in array:
		if function.call_func(element):
			output.append(element)
	return output

enum Tile { GRAS, DIRT }
enum PlantType { TREE, FLOWER }

const PIXEL_PER_TILE = 16
