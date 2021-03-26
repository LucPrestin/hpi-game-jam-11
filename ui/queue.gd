extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var actions: Array
const MAX_ACTIONS: int = 8
const ACTION_MAP: Dictionary = {
	'move_up': Globals.ACTIONS.move_up,
	'move_down': Globals.ACTIONS.move_down,
	'move_left': Globals.ACTIONS.move_left,
	'move_right': Globals.ACTIONS.move_right,
	
	'attack_up': Globals.ACTIONS.atk_up,
	'attack_down': Globals.ACTIONS.atk_down,
	'attack_left': Globals.ACTIONS.atk_left,
	'attack_right': Globals.ACTIONS.atk_right,
}

signal receive_popped_action(action)

# Called when the node enters the scene tree for the first time.
func _ready():
	rset_config('actions', MultiplayerAPI.RPC_MODE_REMOTESYNC)
	if is_network_master():
		self.get_node("../..").z_index = self.get_node("../..").z_index + 1
	
func _on_push_action(action):
	# From CP to CQ
	if self.actions.size() >= self.MAX_ACTIONS:
		return
	var child: Control = preload("res://ui/action_button.tscn").instance()
	self.actions.push_back(action)
	rset_id(1, 'actions', actions)
	child.action = action
	child.make_removal_button(self)
	self.add_child(child)
	
func _on_pop_action(do_send: bool):
	# From CP to CQ and then sent to SQ
	var action = self.actions.pop_front()
	rset_id(1, 'actions', actions)
	if action != null:
		var children = self.get_children()
		self.remove_child(children[0])
	
remotesync func emit_popped_action(action):
	# from CQ to SQ then sent to SP
	emit_signal("receive_popped_action", action)

func _process(_delta: float):
	# Yup, this if is a big bad if. That first bit in parens is to say
	#accept from any client
	if self.is_network_master():
		# Movement
		for input_action in ACTION_MAP.keys():
			if Input.is_action_just_pressed(input_action):
				self._on_push_action(ACTION_MAP[input_action])
		
		# Other Actions
		if Input.is_action_just_pressed("remove_action"):
			self.remove_last_child()


func _on_remove_child(child: Button):
	# From CP to CQ and then sent to SQ
	var i = self.get_children().find(child)
	if i >= 0:
		self.actions.remove(i)
		self.remove_child(child)
		
func remove_last_child():
	var children = self.get_children()
	if children.size() > 0:
		self._on_remove_child(children[children.size()-1])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
