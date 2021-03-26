extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var dirt_layer = get_node("dirt_layer")
	var gras_layer = get_node("gras_layer")
	var desert_layer = get_node("desert_layer")
	
	dirt_layer.hide()
	gras_layer.hide()
	
	var i = 20
	for tile_position in desert_layer.get_used_cells():
		if i > 0:
			var tile = gras_layer.get_cellv(tile_position)
			gras_layer.s
			i = i - 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
