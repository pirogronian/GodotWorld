extends Device

var reg1_val : int = 1
var reg2_val : String = "String wartość"

func _init():
	super()
	print("TestDevice init...")
	add_slot(TransportType.Pipe, false)
	add_slot(TransportType.Pipe, true)
	add_slot(TransportType.Wire, true)
	add_slot(TransportType.Wire, false)
	add_slot(TransportType.Fiber, true)
	print("TestDevice initiated.")
	print("Pipe slots: %d" % get_slots_number(TransportType.Pipe))
	print("Wire slots: %d" % get_slots_number(TransportType.Wire))
	print("Fiber slots: %d" % get_slots_number(TransportType.Fiber))

func get_register_value(_slot_type : int, _slot_num : int, _reg_name : String):
	match _reg_name:
		"Reg1": return reg1_val
		"Reg2": return reg2_val
		"Reg3": return 3.14
		_: return null

func set_register_value(_slot_type : int, _slot_num : int, _reg_name : String, _v) -> bool:
	match _reg_name:
		"Reg1": reg1_val = _v
		"Reg2": reg2_val = _v
		_: return false
	return true

func is_register_readonly(_slot_type : int, _slot_num : int, _reg_name : String) -> bool:
	if not is_slot_accepting_data(_slot_type, _slot_num):
		return true
	match _reg_name:
		"Reg1": return false
		"Reg2": return false
		_: return true
#	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
