extends AnimationPlayer

var direction = "right"

func _ready():
	rset_config("direction", MultiplayerAPI.RPC_MODE_REMOTESYNC)

func set_directionv(new_direction: Vector2):
	if not is_network_master():
		return
	
	match new_direction.normalized().round():
		Vector2(1, 0):
			rset("direction", "right")
		Vector2(-1, 0):
			rset("direction", "left")
		Vector2(0, -1):
			rset("direction", "up")
		Vector2(0, 1):
			rset("direction", "down")

remote func _play_directional_rpc(animation: String):
	self.play(animation + '_' + direction)

func play_directional(animation: String):
	if not is_network_master():
		return
	
	self.play(animation + '_' + direction)
	rpc("_play_directional_rpc", animation)

func enable_falling_track_for(name: String, value: bool):
	var animation = self.get_animation(name)
	animation.track_set_enabled(animation.find_track(@"Sprite:scale"), value)
	animation.track_set_enabled(animation.find_track(@"Sprite:position"), value)
	animation.track_set_enabled(animation.find_track(@"Sprite:modulate"), value)

func set_falling_animation(value: bool):
	self.enable_falling_track_for('death_right', value)
	self.enable_falling_track_for('death_left', value)
	self.enable_falling_track_for('death_up', value)
	self.enable_falling_track_for('death_down', value)
