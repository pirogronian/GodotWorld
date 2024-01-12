extends GridContainer
class_name VectorInfo

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var value : Vector3
var xv : Label
var yv : Label
var zv : Label
var lv : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	xv = get_node("XV")
	yv = get_node("YV")
	zv = get_node("ZV")
	lv = get_node("LV")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if value != null:
		xv.set_text("%f" % value.x)
		yv.set_text("%f" % value.y)
		zv.set_text("%f" % value.z)
		lv.set_text("%f" % value.length())
	pass
