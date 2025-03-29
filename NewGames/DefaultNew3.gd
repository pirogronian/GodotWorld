extends Node3D

@export var firstRun = true

func _init():
	pass

func _ready():
	if not firstRun: return
	firstRun = false
	var dh1 = DeviceHub.new(Device.TransportType.Fiber)
	var dh2 = DeviceHub.new(Device.TransportType.Fiber)
	var dh3 = DeviceHub.new(Device.TransportType.Fiber)
	var dh4 = DeviceHub.new(Device.TransportType.Fiber)
	var dps = load("res://tests/TestDevice.gd")
	var d1 = dps.new()
	var d2 = dps.new()
	var d3 = dps.new()
	var d4 = dps.new()
	
	dh2.connect_device_slot(d1, 0, "Device1")
	dh2.connect_device_slot(d2, 0, "Device2")
	
	dh4.connect_device_slot(d3, 0, "Device3")
	dh4.connect_device_slot(d4, 0, "Device4")
	
	dh1.add_network_node(dh2)
	dh1.add_network_node(dh3)
	dh2.add_network_node(dh4)
	
	add_child(dh1)
	add_child(dh2)
	add_child(dh3)
	add_child(dh4)
	add_child(d1)
	add_child(d2)
	add_child(d3)
	add_child(d4)
	
	dh1.owner = self
	dh2.owner = self
	dh3.owner = self
	dh4.owner = self
	d1.owner = self
	d2.owner = self
	d3.owner = self
	d4.owner = self
	
	var di = get_node("DevicesInspectorWindow") as DevicesInspectorWindow
	di.update()
	di.baseNodePath = dh1.get_path()
