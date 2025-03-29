extends Window
class_name DevicesInspectorWindow

@export var firstRun = true
@export var baseNodePath : NodePath
@export var targetNodePath : NodePath
@export var targetDeviceConn : String
@export var targetRegisterName : String
var container : VBoxContainer
var backButton : Button
var refreshButton : Button
var nodeNameButton : Button
var deviceConnButton : Button
var registerNameLabel : Label
var bottomList : VBoxContainer
#var table : Tree

func onResize():
	container.size = size

func createSkeleton():
	container = VBoxContainer.new()
	#container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(container)
	var topBarContainer = HBoxContainer.new()
	container.add_child(topBarContainer)
	
	refreshButton = Button.new()
	refreshButton.set_text("Refresh")
	refreshButton.pressed.connect(update)
	topBarContainer.add_child(refreshButton)
	
	backButton = Button.new()
	backButton.set_text("Back")
	backButton.pressed.connect(back)
	topBarContainer.add_child(backButton)
	
	var placeBarContainer = HBoxContainer.new()
	topBarContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topBarContainer.add_child(placeBarContainer)
	
	nodeNameButton = Button.new()
	placeBarContainer.add_child(nodeNameButton)
	
	deviceConnButton = Button.new()
	placeBarContainer.add_child(deviceConnButton)
	
	registerNameLabel = Label.new()
	placeBarContainer.add_child(registerNameLabel)
	
	var scroll = ScrollContainer.new()
	container.add_child(scroll)
	
	bottomList = VBoxContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(bottomList)

func clearList():
	while bottomList.get_child_count():
		var item = bottomList.get_child(0)
		bottomList.remove_child(item)
		item.queue_free()

func clear():
	nodeNameButton.visible = false
	deviceConnButton.visible = false
	registerNameLabel.visible = false
	
	clearList()

func populateBaseNode(node : DeviceHub):
	print("populateBaseNode()")
	var nodes = node.get_network_nodes_array()
	for n in nodes:
		var button = Button.new()
		button.text = n.get_name()
		button.pressed.connect(enterTargetNode.bind(n.get_path()))
		bottomList.add_child(button)
		print("Added node: ", n.get_name())

func populateTargetNode(node : DeviceHub):
	print("populateTargetNode()")
	var conns = node.get_device_connections_array()
	for conn in conns:
		var button = Button.new()
		button.text = conn
		button.pressed.connect(enterTargetDevice.bind(conn))
		bottomList.add_child(button)
		print("Added conn: ", conn)

func populateDevice(devCon : String):
	print("populateDevice")
	var node = get_node(targetNodePath)
	var regs = node.get_registers_dictionary(devCon)
	for reg in regs:
		var button = Button.new()
		button.text = reg
		button.pressed.connect(enterTargetRegister.bind(reg))
		bottomList.add_child(button)
		print("Added reg: ", reg)

func populateRegister(val):
	pass

func enterTargetNode(path : String):
	print("Entering ", path)
	clearList()
	targetNodePath = path
	var node = get_node(path) as DeviceHub
	nodeNameButton.text = node.name
	nodeNameButton.visible = true
	populateTargetNode(node)

func enterTargetDevice(conName : String):
	clearList()
	targetDeviceConn = conName
	deviceConnButton.text = conName
	deviceConnButton.visible = true
	populateDevice(conName)

func enterTargetRegister(regName : String):
	clearList()
	targetRegisterName = regName
	registerNameLabel.text = regName
	registerNameLabel.visible = true
	populateRegister(regName)

func clicked(value : String):
	print("Clicked: ", value)

func back():
	if not targetRegisterName.is_empty():
		targetRegisterName = ""
		update()
		return
	if not targetDeviceConn.is_empty():
		targetDeviceConn = ""
		update()
		return
	if not targetNodePath.is_empty():
		targetNodePath = ""
		update()

func update():
	clear()
	if baseNodePath.is_empty(): return
	var baseNode = get_node(baseNodePath) as DeviceHub
	#if node == null: return
	if targetNodePath.is_empty():
		populateBaseNode(baseNode)
		return
	var targetNode = get_node(targetNodePath) as DeviceHub
	if not baseNode.has_network_node(targetNode):
		targetNodePath = ""
		targetDeviceConn = ""
		targetRegisterName = ""
		populateBaseNode(baseNode)
		return
	nodeNameButton.text = targetNode.name
	nodeNameButton.visible = true
	if targetDeviceConn.is_empty():
		populateTargetNode(targetNode)
		return
	var conInfo = targetNode.get_device_connection(targetDeviceConn)
	if conInfo == null:
		targetDeviceConn = ""
		targetRegisterName = ""
		populateTargetNode(targetNode)
		return
	deviceConnButton.text = targetDeviceConn
	deviceConnButton.visible = true
	if targetRegisterName.is_empty():
		populateDevice(targetDeviceConn)
		return
	var regs = targetNode.get_registers_dictionary(targetDeviceConn)
	if not regs.has(targetRegisterName):
		targetRegisterName = ""
		populateDevice(targetDeviceConn)
		return
	var reg = targetNode.register_read(targetDeviceConn, targetRegisterName)
	registerNameLabel.text = targetRegisterName
	registerNameLabel.visible = true
	populateRegister(reg)

func _init():
	size_changed.connect(onResize)
	if firstRun:
		createSkeleton()
		firstRun = false
	
