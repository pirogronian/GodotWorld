extends AcceptDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var transform : Transform
var xtr : Label
var ytr : Label
var ztr : Label
var xrot : Label
var yrot : Label
var zrot : Label

# Called when the node enters the scene tree for the first time.
func _ready():
#	transform = get_parent().transform
	xtr = get_node("VBoxContainer/GridContainer/XTr")
	ytr = get_node("VBoxContainer/GridContainer/YTr")
	ztr = get_node("VBoxContainer/GridContainer/ZTr")
	xrot = get_node("VBoxContainer/GridContainer/XRot")
	yrot = get_node("VBoxContainer/GridContainer/YRot")
	zrot = get_node("VBoxContainer/GridContainer/ZRot")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var transform = find_parent("Player").transform
	var orig = transform.origin
	xtr.set_text("%f" % orig.x)
	ytr.set_text("%f" % orig.y)
	ztr.set_text("%f" % orig.z)
	var basis = transform.basis
	var vrot = basis.get_euler()
	xrot.set_text("%f" % vrot.x)
	yrot.set_text("%f" % vrot.y)
	zrot.set_text("%f" % vrot.z)
#	pass 


