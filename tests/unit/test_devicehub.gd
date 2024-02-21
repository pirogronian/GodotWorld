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
	var dh1 = Device.DeviceHub.new(Device.TransportType.Generic)
	var dh2 = Device.DeviceHub.new(Device.TransportType.Generic)
	var dh3 = Device.DeviceHub.new(Device.TransportType.Wire)
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
	var dh1 = Device.DeviceHub.new(Device.TransportType.Generic)
	var dh2 = Device.DeviceHub.new(Device.TransportType.Generic)
	var dh3 = Device.DeviceHub.new(Device.TransportType.Generic)
	var dh4 = Device.DeviceHub.new(Device.TransportType.Generic)
	
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

