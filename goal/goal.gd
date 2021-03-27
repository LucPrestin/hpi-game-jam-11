extends Node2D

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_radius():
	return ($WinArea/WinCollisionArea.shape as CircleShape2D).radius

func overlaps_body(body: Node):
	return $WinArea.overlaps_body(body)

func _on_win_body_entered(_body):
	if is_network_master():
		Globals.get_level().rpc("check_win_condition")
