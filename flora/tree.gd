extends StaticBody2D
class_name Flora

const TIME_PER_STAGE = 3
const MAX_GROWTH_STAGE = 3

export var growth_stage : int = 1 setget _set_growth_stage
var time_until_growth = TIME_PER_STAGE


# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
	rset_config("growth_stage", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	_set_growth_stage(growth_stage)
	pass # Replace with function body.

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
