extends StaticBody2D
class_name Flora

const TIME_PER_STAGE = 3
const MAX_GROWTH_STAGE = 3

export var growth_stage : int = 1 setget _set_growth_stage
export var is_burning: bool = false setget _set_burning_state
var time_until_growth = TIME_PER_STAGE
var listener = null
const OFFSET = 8


# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
	rset_config("growth_stage", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("is_burning", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	_set_growth_stage(growth_stage)
	_set_burning_state(is_burning)

func _process(delta):
	if is_network_master() and growth_stage < MAX_GROWTH_STAGE:
		time_until_growth -= delta
		if time_until_growth <= 0:
			time_until_growth = MAX_GROWTH_STAGE
			rset("growth_stage", growth_stage + 1)

func _set_growth_stage(new_stage: int):
	growth_stage = new_stage
	var scale = growth_stage as float / MAX_GROWTH_STAGE as float
	set_scale(Vector2(scale, scale))

func _set_burning_state(new_burning_state: bool):
	is_burning = new_burning_state
	_set_surrounding_tiles()

func _set_surrounding_tiles():
	var pos = get_position()
	
	_set_tile(pos.x-OFFSET, pos.y-OFFSET)
	_set_tile(pos.x, pos.y-OFFSET)
	_set_tile(pos.x-OFFSET, pos.y)
	_set_tile(pos.x-OFFSET, pos.y+OFFSET)
	_set_tile(pos.x, pos.y)
	_set_tile(pos.x+OFFSET, pos.y-OFFSET)
	_set_tile(pos.x, pos.y+OFFSET)
	_set_tile(pos.x+OFFSET, pos.y)
	_set_tile(pos.x+OFFSET, pos.y+OFFSET)
	#+/-16 or +/-8? 16 would change all 9 tiles around tree, but 8 looks better

func _set_tile (x: int, y: int):
	var level = get_parent().get_parent()
	if is_burning:
		level.set_dirt_tile(x, y)
	else:
		level.set_gras_tile(x, y)
