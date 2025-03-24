extends GutTest

func before_each():
	gut.p("ran setup", 2)

func after_each():
	gut.p("ran teardown", 2)

func before_all():
	gut.p("ran run setup", 2)

func after_all():
	gut.p("ran run teardown", 2)

func test_links():
	var dh1 = DeviceHub.new(Device.TransportType.Generic)
	var dh2 = DeviceHub.new(Device.TransportType.Generic)
	var dh3 = DeviceHub.new(Device.TransportType.Wire)
	assert_eq(dh1.get_transport_type(), Device.TransportType.Generic)
	assert_eq(dh1.get_device_connections_number(), 0)
	assert_eq(dh1.get_network_links_number(), 0)
	assert_eq(dh1.has_network_neighbour(dh1), false)
	assert_eq(dh1.has_network_neighbour(dh2), false)
	assert_eq(dh1.has_network_neighbour(dh3), false)
	assert_eq(dh1.is_network_coordinator(), true)
	assert_eq(dh2.get_transport_type(), Device.TransportType.Generic)
	assert_eq(dh2.get_device_connections_number(), 0)
	assert_eq(dh2.get_network_links_number(), 0)
	assert_eq(dh3.get_transport_type(), Device.TransportType.Wire)
	assert_eq(dh3.get_device_connections_number(), 0)
	assert_eq(dh3.get_network_links_number(), 0)
	assert_eq(dh1.add_network_link(dh3), 0)
	assert_eq(dh1.get_network_links_number(), 0)
	assert_eq(dh3.get_network_links_number(), 0)
	
	assert_eq(dh1.add_network_link(dh2), 1)
	assert_eq(dh1.get_network_links_number(), 1)
	
	dh1.queue_free()
	dh2.queue_free()
	dh3.queue_free()
	
func test_network():
	var dh1 = DeviceHub.new(Device.TransportType.Generic)
	var dh2 = DeviceHub.new(Device.TransportType.Generic)
	var dh3 = DeviceHub.new(Device.TransportType.Generic)
	var dh4 = DeviceHub.new(Device.TransportType.Generic)
	
	assert_eq(dh1.get_network_size(), 1)
	assert_eq(dh2.get_network_size(), 1)
	assert_eq(dh3.get_network_size(), 1)
	assert_eq(dh4.get_network_size(), 1)
	
	assert_eq(dh1.add_network_node(dh2), 1)
	assert_eq(dh1.get_network_size(), 2)
	assert_eq(dh2.get_network_size(), 2)
	assert_eq(dh1.has_network_neighbour(dh2), true)
	assert_eq(dh2.has_network_neighbour(dh1), true)
	
	assert_eq(dh2.add_network_node(dh3), 1)
	assert_eq(dh1.get_network_size(), 3)
	assert_eq(dh2.get_network_size(), 3)
	assert_eq(dh3.get_network_size(), 3)
	assert_eq(dh1.has_network_neighbour(dh2), true)
	assert_eq(dh2.has_network_neighbour(dh1), true)
	assert_eq(dh2.has_network_neighbour(dh3), true)
	assert_eq(dh3.has_network_neighbour(dh2), true)
	
	assert_eq(dh3.add_network_node(dh1), 1)
	assert_eq(dh1.get_network_size(), 3)
	assert_eq(dh2.get_network_size(), 3)
	assert_eq(dh3.get_network_size(), 3)
	assert_eq(dh3.has_network_neighbour(dh1), true)
	assert_eq(dh1.has_network_neighbour(dh3), true)
	
	assert_eq(dh1.delete_network_node(dh2), 0)
	assert_eq(dh1.get_network_size(), 3)
	assert_eq(dh2.get_network_size(), 3)
	assert_eq(dh3.get_network_size(), 3)
	assert_eq(dh1.has_network_neighbour(dh2), false)
	assert_eq(dh2.has_network_neighbour(dh1), false)
	assert_eq(dh1.has_network_neighbour(dh3), true)
	assert_eq(dh3.has_network_neighbour(dh1), true)
	
	assert_eq(dh1.delete_network_node(dh3), 0)
	assert_eq(dh1.get_network_size(), 1)
	assert_eq(dh2.get_network_size(), 2)
	assert_eq(dh3.get_network_size(), 2)
	assert_eq(dh1.has_network_neighbour(dh2), false)
	assert_eq(dh2.has_network_neighbour(dh1), false)
	assert_eq(dh1.has_network_neighbour(dh3), false)
	assert_eq(dh3.has_network_neighbour(dh1), false)
	
func test_saving_network():
	var sc = Node.new()
	var dh1 = DeviceHub.new(Device.TransportType.Generic)
	var dh2 = DeviceHub.new(Device.TransportType.Generic)
	var dh3 = DeviceHub.new(Device.TransportType.Generic)
	var dh4 = DeviceHub.new(Device.TransportType.Generic)
	
	dh1.set_name("dh1")
	dh2.set_name("dh2")
	dh3.set_name("dh3")
	dh4.set_name("dh4")
	
	add_child(sc)
	sc.add_child(dh1)
	dh1.set_owner(sc)
	sc.add_child(dh2)
	dh2.set_owner(sc)
	sc.add_child(dh3)
	dh3.set_owner(sc)
	sc.add_child(dh4)
	dh4.set_owner(sc)
	
	dh1.add_network_node(dh2)
	dh1.add_network_node(dh3)
	dh3.add_network_node(dh4)
	
	assert_true(dh1.has_network_neighbour(dh2))
	assert_true(dh2.has_network_neighbour(dh1))
	assert_true(dh1.has_network_neighbour(dh3))
	assert_true(dh3.has_network_neighbour(dh1))
	assert_true(dh3.has_network_neighbour(dh4))
	assert_true(dh4.has_network_neighbour(dh3))
	print("First network made.")
	
	sc.propagate_call("game_saving")
	
	const savePath = "user://tests/deviceHubSaving.tscn"
	
	var ps := PackedScene.new()
	ps.pack(sc)
	ResourceSaver.save(ps, savePath)
	remove_child(sc)
	sc.queue_free()
	
	ps = load(savePath)
	sc = ps.instantiate()
	dh1 = sc.get_node("dh1")
	dh2 = sc.get_node("dh2")
	dh3 = sc.get_node("dh3")
	dh4 = sc.get_node("dh4")
	
	add_child(sc)
	
	sc.propagate_call("game_loaded")
	
	assert_true(dh1.has_network_neighbour(dh2))
	assert_true(dh2.has_network_neighbour(dh1))
	assert_true(dh1.has_network_neighbour(dh3))
	assert_true(dh3.has_network_neighbour(dh1))
	assert_true(dh3.has_network_neighbour(dh4))
	assert_true(dh4.has_network_neighbour(dh3))

func test_saving_device_connections():
	print("test_saving_device_connections():")
	var n = Node.new()
	var dh := DeviceHub.new(Device.TransportType.Fiber)
	var TDev = load("res://tests/TestDevice.gd")
	var td1 = TDev.new()
	var td2 = TDev.new()
	var td3 = TDev.new()
	
	dh.set_name("dh")
	td1.set_name("td1")
	td2.set_name("td2")
	td3.set_name("td3")
	n.add_child(dh)
	n.add_child(td1)
	n.add_child(td2)
	n.add_child(td3)
	dh.set_owner(n)
	td1.set_owner(n)
	td2.set_owner(n)
	td3.set_owner(n)
	add_child(n)
	
	assert_true(dh.connect_device_slot(td1, 0, "TestDevice1Connection"))
	assert_true(dh.connect_device_slot(td2, 0, "TestDevice2Connection"))
	
	n.propagate_call("game_saving")
	
	var ps = PackedScene.new()
	ps.pack(n)
	remove_child(n)
	n.queue_free()
	
	const path = "user://tests/savingTest.tscn"
	ResourceSaver.save(ps, path)
	ps = load(path)
	n = ps.instantiate()
	
	add_child(n)
	#for node in n.get_children():
		#print(node)
	dh = n.get_node("dh")
	td1 = n.get_node("td1")
	td2 = n.get_node("td2")
	td3 = n.get_node("td3")
	
	n.propagate_call("game_loaded")
	
	assert_true(td1.is_slot_connected(Device.TransportType.Fiber, 0))
	
	assert_eq(dh.get_device_connections_number(), 2)
	
	var conInfo = dh.get_device_connection("TestDevice1Connection")
	assert_ne(conInfo, null)
	if conInfo != null:
		assert_eq(conInfo.device, td1)
		assert_eq(conInfo.slot_num, 0)
	
	conInfo = dh.get_device_connection("TestDevice2Connection")
	assert_ne(conInfo, null)
	if conInfo != null:
		assert_eq(conInfo.device, td2)
		assert_eq(conInfo.slot_num, 0)
	
