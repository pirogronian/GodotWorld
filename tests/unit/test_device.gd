extends GutTest
func before_each():
	gut.p("ran setup", 2)

func after_each():
	gut.p("ran teardown", 2)

func before_all():
	gut.p("ran run setup", 2)

func after_all():
	gut.p("ran run teardown", 2)

func test_empty_slots():
	var d1 = Device.new()
	assert_true(d1.get_slots_number(Device.TransportType.Generic) == 0)
	assert_true(d1.get_slots_number(Device.TransportType.Pipe) == 0)
	assert_true(d1.get_slots_number(Device.TransportType.Wire) == 0)
	assert_true(d1.get_slots_number(Device.TransportType.Fiber) == 0)
	assert_true(d1.get_slots_number(6) == 0)
	assert_true(d1.get_slot_info(Device.TransportType.Pipe, 0) == null)
	assert_true(d1.get_slot_info(Device.TransportType.Pipe, 1) == null)
	assert_true(d1.get_slot_info(Device.TransportType.Pipe, 2) == null)
	d1.queue_free()

func test_one_slots():
	var d1 = Device.new()
	assert_true(d1.add_slot(Device.TransportType.Generic, false))
	assert_true(d1.get_slots_number(Device.TransportType.Generic) == 1)
	var si1 = d1.get_slot_info(Device.TransportType.Generic, 0)
	assert_true(si1 != null)
	assert_true(si1.connected_hub == null)
	assert_true(si1.data_capable == false)
	assert_true(d1.add_slot(Device.TransportType.Generic, true))
	assert_true(d1.get_slots_number(Device.TransportType.Generic) == 2)
	var si2 = d1.get_slot_info(Device.TransportType.Generic, 1)
	assert_true(si2 != null)
	assert_true(si2.connected_hub == null)
	assert_true(si2.data_capable == true)
	assert_true(d1.get_slot_info(Device.TransportType.Pipe, 0) == null)
	assert_true(d1.get_slot_info(Device.TransportType.Wire, 1) == null)
	assert_true(d1.get_slot_info(Device.TransportType.Fiber, 2) == null)
	d1.queue_free()

func test_empty_registers():
	var d1 = Device.new()
	assert_true(d1.read_from_register(Device.TransportType.Pipe, 0, "some_register") == null)
	assert_true(d1.add_slot(Device.TransportType.Pipe, false))
	assert_true(d1.read_from_register(Device.TransportType.Pipe, 0, "some_register") == null)
	assert_true(d1.add_slot(Device.TransportType.Pipe, true))
	assert_true(d1.read_from_register(Device.TransportType.Pipe, 1, "some_register") == null)
	d1.queue_free()

func test_hub_connections():
	var d1 = Device.new()
	var h1 = DeviceHub.new(Device.TransportType.Wire)
	d1.add_slot(Device.TransportType.Wire, false)
	d1.add_slot(Device.TransportType.Wire, true)
	assert_true(h1.get_transport_type() == Device.TransportType.Wire)
	assert_true(h1.get_device_connections_number() == 0)
	assert_true(h1.connect_device_slot(d1, 0, "TestConnection"))
	assert_true(h1.get_device_connections_number() == 1)

func test_empty_device_slots():
	var d1 = Device.new()
	assert_eq(d1.add_slot(Device.TransportType.Generic, false), true)
	assert_eq(d1.add_slot(Device.TransportType.Generic, true), true)
	assert_eq(d1.get_slots_number(Device.TransportType.Generic), 2)

func test_device_registers():
	print("GUT test: TestDevice")
	var TDev = load("res://tests/TestDevice.gd")
	var td = TDev.new()
	var t_g = Device.TransportType.Generic
	var t_p = Device.TransportType.Pipe
	var t_w = Device.TransportType.Wire
	var t_f = Device.TransportType.Fiber
	assert_eq(td.get_slots_number(Device.TransportType.Generic), 0)
	assert_eq(td.get_slots_number(Device.TransportType.Pipe), 2)
	assert_eq(td.get_slots_number(Device.TransportType.Wire), 2)
	assert_eq(td.get_slots_number(Device.TransportType.Fiber), 1)
	assert_true(td.is_register_readonly(Device.TransportType.Pipe, 0, "Reg1"))
	assert_eq(td.is_register_readonly(Device.TransportType.Pipe, 1, "Reg1"), false)
	assert_eq(td.is_register_readonly(Device.TransportType.Fiber, 0, "Reg1"), false)
	assert_true(td.is_register_readonly(Device.TransportType.Pipe, 0, "Reg3"))
	assert_true(td.is_register_readonly(Device.TransportType.Pipe, 0, "Reg4"))
	assert_true(td.is_register_readonly(Device.TransportType.Pipe, 3, "Reg1"))
	assert_eq(td.read_from_register(t_g, 0, "Reg1"), null)
	assert_eq(td.read_from_register(t_p, 0, "Reg1"), null)
	assert_eq(td.read_from_register(t_p, 1, "Reg1"), 1)
	assert_eq(td.read_from_register(t_w, 0, "Reg1"), 1)
	assert_eq(td.read_from_register(t_w, 1, "Reg1"), null)
	assert_eq(td.read_from_register(t_f, 0, "Reg1"), 1)
	assert_false(td.write_to_register(t_g, 0, "Reg1", 2))
	assert_true(td.write_to_register(t_f, 0, "Reg1", 2))
	assert_eq(td.read_from_register(t_g, 0, "Reg1"), null)
	assert_eq(td.read_from_register(t_p, 0, "Reg1"), null)
	assert_eq(td.read_from_register(t_p, 1, "Reg1"), 2)
	assert_eq(td.read_from_register(t_w, 0, "Reg1"), 2)
	assert_eq(td.read_from_register(t_w, 1, "Reg1"), null)
	assert_eq(td.read_from_register(t_f, 0, "Reg1"), 2)
