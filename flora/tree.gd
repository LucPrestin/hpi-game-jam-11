extends StaticBody2D
class_name Flora

const TIME_BETWEEN_SPREADINGS = 3
const TIME_PER_STAGE = 3
const MAX_GROWTH_STAGE = 3
const OFFSET = 8

export var growth_stage : int = 1 setget _set_growth_stage
export var is_burning: bool = false setget _set_burning_state

var time_until_growth = TIME_PER_STAGE
var time_until_fire_spreads = TIME_BETWEEN_SPREADINGS


# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
	rset_config("growth_stage", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	rset_config("is_burning", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	_set_growth_stage(growth_stage)
	_set_burning_state(is_burning)

func _process(delta):
	if is_network_master():
		if growth_stage < MAX_GROWTH_STAGE:
			time_until_growth -= delta
			if time_until_growth <= 0:
				time_until_growth = TIME_PER_STAGE
				rset("growth_stage", growth_stage + 1)
		if is_burning:
			time_until_fire_spreads -= delta
			if time_until_fire_spreads <= 0:
				time_until_fire_spreads = TIME_BETWEEN_SPREADINGS
				_spread_fire()

func start_burning():
	rset("is_burning", true)

func _spread_fire():
	var surrounding_trees = Globals.get_level().get_surrounding_trees(get_position())
	
	for tree in surrounding_trees:
		tree.start_burning()

func _set_growth_stage(new_stage: int):
	growth_stage = new_stage
	var scale = growth_stage as float / MAX_GROWTH_STAGE as float
	set_scale(Vector2(scale, scale))

func _set_burning_state(new_burning_state: bool):
	is_burning = new_burning_state
	_set_surrounding_tiles()

func _set_surrounding_tiles():
	var pos = get_position()
	
	var offset_multiplier_x = -1
	var offset_multiplier_y = -1
	
	while offset_multiplier_x <= 1:
		while offset_multiplier_y <= 1:
			_set_tile(pos.x + OFFSET * offset_multiplier_x, pos.y + OFFSET * offset_multiplier_y)
			offset_multiplier_y += 1
		offset_multiplier_x += 1

func _set_tile (x: int, y: int):
	if Globals.get_level() == null:
		return

	if is_burning:
		Globals.get_level().set_dirt_tile(x, y)
	else:
		Globals.get_level().set_gras_tile(x, y)
