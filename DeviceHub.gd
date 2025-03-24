extends Node
class_name DeviceHub

class DeviceConnection:
	var device : Device
	var slot_num : int
	func _init(dev : Device, s_num : int):
		device = dev
		slot_num = s_num
@export var type : int
var connections : Dictionary
var network_neighbours : Dictionary = {}
var network_nodes : Dictionary = { self : true }
var network_coordinator : DeviceHub = self

@export var saved_network_links : Array
@export var saved_device_connections : Dictionary

func get_neighbours() -> Dictionary:
	return network_neighbours

func _init(t : int = Device.TransportType.Generic):
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
	if has_network_neighbour(node): return 0
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

func game_loaded():
	for path in saved_network_links:
		var devhub = get_node(path)
		add_network_node(devhub)
	
	for conname in saved_device_connections:
		var conrest = saved_device_connections[conname]
		var dev = get_node(conrest["device"])
		dev.game_loaded()  # This is needed for proper loading order
		var slot = conrest["slot"]
		connect_device_slot(dev, slot, conname)

func game_saving():
	saved_network_links.clear()
	for neighbour in network_neighbours:
		saved_network_links.append(neighbour.get_path())
	
	for conname in connections:
		var connection = connections[conname]
		saved_device_connections[conname] = { "device" : connection.device.get_path(), "slot" : connection.slot_num }
