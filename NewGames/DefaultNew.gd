extends Node3D

# Declare member variables here. Examples:
var a = 0
# var b = "text"
@export var first_run : bool = true
@export var frame_nr : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
#	print(Globals.test_global_variable)
	print("Starting at frame #", frame_nr)
	if first_run:
		var cs = get_node("CameraSwitcher")
		cs.cams.append(NodePath("../Player/Camera"))
		cs.cams.append(NodePath("../Cams/ThirdPersonCameraRoot"))
		cs.cams.append(NodePath("../Cams/ThirdPersonCameraRoot2"))
		cs.cams.append(NodePath("../Cams/ThirdPersonCameraRoot3"))
	first_run = false
#	print("First run set to ", first_run)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	frame_nr = frame_nr + 1
#	print(_delta)
	if a > 100: a = 0
	a = a + 1
	get_node("Label").set_text("%d" % a)
#	pass
