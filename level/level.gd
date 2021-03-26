extends Node2D

const SURROUNDING_TILE_RANGE = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_forest():
	return $forest.get_children()

func get_surrounding_trees(position: Vector2):
	var surrounding_trees = []
	
	for tree in $forest.get_children():
		var tree_position = tree.get_position() / Globals.PIXEL_PER_TILE
		if position.distance_to(tree_position) <= SURROUNDING_TILE_RANGE:
			surrounding_trees.append(tree)
	
	return surrounding_trees

func set_tile(position: Vector2, tile):
	match tile:
		Globals.Tile.GRAS:
			_set_tile($gras_layer, position)
		Globals.Tile.DIRT:
			_set_tile($dirt_layer, position)

func _set_tile(tileMap: TileMap, position: Vector2):
	if $desert_layer.get_cellv(position) == TileMap.INVALID_CELL:
		return
	
	tileMap.set_cellv(position, 0)
	tileMap.update_bitmask_area(position)
