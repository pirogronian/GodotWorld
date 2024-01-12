extends Node3D
class_name GravityCenter

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var gravity_multiplier : float = 1
@export var gravity_group : String = "GravityAcceptors"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("GravityCenter entered tree for the first time.")
	pass # Replace with function body.

func _enter_tree():
	print("GravityCenter entered tree.")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	var bodies = get_tree().get_nodes_in_group(gravity_group)
	for body in bodies:
		if body == self: continue
		var rel_pos = global_position - body.global_position
		var dist2 = rel_pos.length_squared()
		if dist2 <= 0: continue
		var sf = gravity_multiplier * body.gravity_scale * body.mass / dist2
		var vf = sf * rel_pos.normalized()
		body.apply_central_force(vf)
	pass
