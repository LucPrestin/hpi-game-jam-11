extends Node2D

const tile_pixel_factor = 16

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_gras_tilev(position: Vector2):
	_set_tilev(get_node("gras_layer") as TileMap, position)

func set_gras_tile(x: int, y: int):
	_set_tile(get_node("gras_layer") as TileMap, x, y)

func set_dirt_tile(x: int, y: int):
	_set_tile(get_node("dirt_layer") as TileMap, x, y)

func set_dirt_tilev(position: Vector2):
	_set_tilev(get_node("dirt_layer") as TileMap, position)

func _set_tile(tileMap: TileMap, x: int, y: int):
	_set_tilev(tileMap, Vector2(x, y))

func _set_tilev(tileMap: TileMap, position: Vector2):
	position = position / tile_pixel_factor
	tileMap.set_cellv(position, 0)
	tileMap.update_bitmask_area(position)
