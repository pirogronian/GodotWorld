extends Node
class_name Device

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class SlotInfo:
	var connected_hub : Node
	var data_capable : bool
	func _init(data : bool, hub : Node = null):
		data_capable = data
		connected_hub = hub

class HubConnection:
	var hub : Node
#	var type : int
	var slot_num : int
	func _init(h : Node, s_num : int):
		hub = h
#		type = t
		slot_num = s_num

enum TransportType { Generic, Pipe, Wire, Fiber, Max }

var slot_types : Array

func _init():
	#print("Creating transport type arrays...")
	slot_types.resize(TransportType.Max)
	slot_types[TransportType.Generic] = []
	slot_types[TransportType.Pipe] = []
	slot_types[TransportType.Wire] = []
	slot_types[TransportType.Fiber] = []
	#print("Created types number: %d" % slot_types.size())

func get_slots_by_type(t : int):
	if t < 0 or t >= slot_types.size():
		print("Wrong slot type! (%d)" % t)
		return null
	return slot_types[t]

func get_slot_info(type : int, num : int) -> SlotInfo:
	if type < 0 or type >= slot_types.size():
		return null
	var slots = slot_types[type]
	if slots == null:
		return null
	if num < 0 or num >= slots.size():
		return null
	return slots[num]

#func is_slot_connected(_slot_type : int, _slot_num : int) -> bool:
#	var si = get_slot_info(_slot_type, _slot_num)
#	if si == null:
#		return false
#	return si.connected_hub != null
#
#func is_slot_data_capable(_slot_type : int, _slot_num : int) -> bool:
#	var si = get_slot_info(_slot_type, _slot_num)
#	if si == null:
#		return false
#	return si.data_capable

func add_slot(t : int, d : bool) -> bool:
	var slots = get_slots_by_type(t)
	if slots != null:
		slots.append(SlotInfo.new(d))
		return true
	else:
		return false

func get_register_value(_slot_type : int, _slot_num : int, _reg_name : String):
	print("Dummy get_register_value(%d, %d, %s)" % [ _slot_type, _slot_num, _reg_name])
	pass

func read_from_register(slot_type : int, slot_num : int, reg_name : String):
	var si = get_slot_info(slot_type, slot_num)
	if si and si.data_capable:
		return get_register_value(slot_type, slot_num, reg_name)
	pass

func set_register_value(_slot_type : int, _slot_num : int, _reg_name : String, _v) -> bool:
	print("Dummy set_register_value(%d, %d, %s)" % [_slot_type, _slot_num, _reg_name], _v)
	return false

func write_to_register(slot_type : int, slot_num : int, reg_name : String, v) -> bool:
	var si = get_slot_info(slot_type, slot_num)
	if si and si.data_capable:
		return set_register_value(slot_type, slot_num, reg_name, v)
	else:
		return false

func is_register_readonly(_slot_type : int, _slot_num : int, _reg_name : String) -> bool:
	return true

func get_registers(_slot_type : int, _slot_num : int) -> Dictionary:
	return {}

func is_slot_accepting_data(slot_type : int, slot_num : int) -> bool:
	var si = get_slot_info(slot_type, slot_num)
	if si == null:
		return false
	return si.data_capable

func is_slot_connected(slot_type : int, slot_num : int) -> bool:
	var si = get_slot_info(slot_type, slot_num)
	if si:
		return si.connected_hub
	return false

func get_slots_number(slot_type : int) -> int:
	var ss = get_slots_by_type(slot_type)
	if ss:
		return ss.size()
	return 0

func set_connection(dev_hub : Node, slot_type : int, slot_num : int) -> bool:
	var si = get_slot_info(slot_type, slot_num)
	if si:
		if si.connected_hub:
			return false
		else:
			si.connected_hub = dev_hub
			return true
	return false

func unset_connection(slot_type : int, slot_num : int) -> bool:
	var si = get_slot_info(slot_type, slot_num)
	if si:
		if si.connected_hub:
			si.connected_hub = null
			return true
		else:
			return false
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
