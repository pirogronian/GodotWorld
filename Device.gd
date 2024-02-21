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

class DeviceHub:
	extends Node
	class DeviceConnection:
		var device : Device
		var slot_num : int
		func _init(dev : Device, s_num : int):
			device = dev
			slot_num = s_num
	var type : int
	var connections : Dictionary
	var network_neighbours : Dictionary = {}
	var network_nodes : Dictionary = { self : true }
	var network_coordinator : DeviceHub = self
	
	func _init(t : int):
		type = t
	
	func get_transport_type() -> int:
		return type
	
	func get_device_connections_number() -> int:
		return connections.size()
	
	func get_device_connection(cname : String):
		return connections.get(cname)
	
	func has_device_connection(cname : String) -> bool:
		return get_device_connection(cname) != null
	
	func connect_device_slot(dev : Device, slot_num : int, cname : String) -> bool:
		print("Hub.connect_device_slot(dev, %d, %s)" % [slot_num, cname])
		var con = get_device_connection(cname)
		if con:
			print("Device connection already exists!")
			return false
		var si = dev.get_slot_info(type, slot_num)
		if si == null:
			print("Slot doesnt exists!")
			return false
		if si.connected_hub != null:
			print("Slot already connected!")
			return false
		var newcon : DeviceConnection = DeviceConnection.new(dev, slot_num)
		connections[cname] = newcon
		si.connected_hub = self
		return true
	
	func disconnect_device_slot(cname : String) -> bool:
		if connections.has(cname): return false
		var si = connections.get(cname)
		si.connected_hub = null
		connections.erase(cname)
		return true
	
	func get_network_links_number() -> int:
		return network_neighbours.size()
	
	func has_network_neighbour(node : DeviceHub) -> bool:
		return network_neighbours.has(node)
	
	func is_network_coordinator() -> bool:
		return network_coordinator == self
	
	func get_network_size() -> int:
		return network_coordinator.network_nodes.size()
	
	func add_network_link(node : DeviceHub) -> int:
		if type != node.type:
			print("add_network_link: incompatybile types: %d != %d" % [type, node.type])
			return 0
		if network_neighbours.has(node):
			network_neighbours[node] = network_neighbours[node] + 1
			return network_neighbours[node]
		network_neighbours[node] = 1
		return 1
	
	func make_node_list(list : Dictionary = {}) -> Dictionary:
		if list.has(self): return list
		list[self] = true
		for node in network_neighbours:
			node.make_node_list(list)
		return list
	
	func add_network_node(node : DeviceHub) -> int:
		var ret = add_network_link(node)
		var ret2 = node.add_network_link(self)
		if ret != ret2:
			print("add_network_node: %d != %d!" % [ret, ret2])
		if ret == 1 and self.network_coordinator != node.network_coordinator:
			var list2 = node.network_coordinator.network_nodes
			for n in list2:
				n.network_coordinator = network_coordinator
			network_coordinator.network_nodes.merge(list2)
		
		return ret
	
	func delete_network_link(node : DeviceHub, all : bool = false) -> int:
		if !network_neighbours.has(node):
			return -1
		if all:
			network_neighbours.erase(node)
			return 0
		network_neighbours[node] = network_neighbours[node] - 1
		if network_neighbours[node] > 0:
			return network_neighbours[node]
		network_neighbours.erase(node)
		return 0
	
	func delete_network_node(node : DeviceHub, all : bool = false) -> int:
		var ret1 = delete_network_link(node, all)
		var ret2 = node.delete_network_link(self, all)
		if ret1 != ret2:
			print("delete_network_node: %d != %d!" % [ret1, ret2])
		if ret1 > 0: return ret1
		var list2 = node.make_node_list()
		if list2.has(self): return ret1
		var list1 = network_coordinator.network_nodes
		var sc : bool
		if list2.has(network_coordinator):
			sc = false
		else:
			sc = true
		for n in list2:
			if sc:
				n.network_coordinator = node
			list1.erase(n)
		if !sc:
			network_nodes = list1
			for n in list1:
				n.network_coordinator = self
		node.network_nodes = list2
		return ret1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
