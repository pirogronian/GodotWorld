extends Node3D

var first_run : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	var cs = get_node("CameraSwitcher")
	if first_run:
		print("First run. Set camera focus.")
		cs.cams.append(NodePath("../ThirdPersonCamera"))
		cs.focus_cam(0)
	else:
		cs.restore_focus()
	first_run = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
