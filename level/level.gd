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

func set_gras_tile(position: Vector2):
	_set_tile(get_node("gras_layer") as TileMap, position)

func set_dirt_tile(position: Vector2):
	_set_tile(get_node("dirt_layer") as TileMap, position)

func _set_tile(tileMap: TileMap, position: Vector2):
	position = position / tile_pixel_factor
	tileMap.set_cellv(position, 0)
	tileMap.update_bitmask_area(position)
