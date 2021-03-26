extends Node2D

const tile_pixel_factor = 16
const SURROUNDING_TILE_RANGE = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_surrounding_trees(position: Vector2):
	var surrounding_trees = []
	
	var grid_position = (position / tile_pixel_factor).round()
	var forest = get_node("trees").get_children()
	
	for offset_x in range(SURROUNDING_TILE_RANGE * -1, SURROUNDING_TILE_RANGE):
		for offset_y in range(SURROUNDING_TILE_RANGE * -1, SURROUNDING_TILE_RANGE):
			for tree in forest:
				var tree_grid_position = (tree.get_position() / tile_pixel_factor).round()
				if tree_grid_position == grid_position + Vector2(offset_x, offset_y):
					surrounding_trees.append(tree)
	
	return surrounding_trees

func set_gras_tile(x: int, y: int):
	_set_tile(get_node("gras_layer") as TileMap, x, y)

func set_dirt_tile(x: int, y: int):
	_set_tile(get_node("dirt_layer") as TileMap, x, y)

func _set_tile(tileMap: TileMap, x: int, y: int):
	var position = Vector2(x, y)
	position = position / tile_pixel_factor
	
	var desert = get_node("desert_layer") as TileMap
	if desert.get_cellv(position) == TileMap.INVALID_CELL:
		return
	
	tileMap.set_cellv(position, 0)
	tileMap.update_bitmask_area(position)
