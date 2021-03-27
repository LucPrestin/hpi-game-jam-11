extends Node2D

const SURROUNDING_TILE_RANGE = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

master func place_flower(position: Vector2):
	var new_flower = _create_new_flora(position)
	new_flower.type = Globals.PlantType.FLOWER
	_spawn_flora(new_flower)

master func place_tree(position: Vector2):
	var new_tree = _create_new_flora(position)
	new_tree.type = Globals.PlantType.TREE
	_spawn_flora(new_tree)

func _spawn_flora(flora):
	Globals.get_level().get_node("forest").add_child(flora)
	Globals.get_game().spawn_object_on_clients(flora)

func _create_new_flora(position: Vector2):
	var new_flora = load("res://flora/flora.tscn").instance()
	new_flora.position = position
	new_flora.growth_stage = 1
	
	return new_flora

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
