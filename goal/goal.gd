extends Area2D

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	if is_network_master():
		Globals.get_level().rpc("check_win_condition")

func get_radius():
	return ($WinArea.shape as CircleShape2D).radius