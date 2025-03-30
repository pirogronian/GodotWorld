extends Window
class_name DevicesInspectorWindow

@export var firstRun = true
@export var baseNodePath : NodePath
@export var targetNodePath : NodePath
@export var targetDeviceConn : String
@export var targetRegisterName : String

const _Container = "Container"
const _BackButton = "BackButton"
const _RefreshButton = "RefreshButton"
const _NodeNameButton = "NodeNameButton"
const _DeviceConnButton = "DeviceConnButton"
const _RegisterNameLabel = "RegisterNameLabel"
const _BottomList = "BottomList"
const _RegisterWidget = "RegisterWidget"
const _RegisterValueLabel = "RegisterValueLabel"

var container : VBoxContainer
var backButton : Button
var refreshButton : Button
var nodeNameButton : Button
var deviceConnButton : Button
var registerNameLabel : Label
var bottomList : VBoxContainer
var registerWidget : VBoxContainer
var registerValueLabel : Label
#var registerTextEdit : TextEdit
#var registerSpinBox : SpinBox
#var registerTypeMenu : OptionButton
#var table : Tree

func onResize():
	container.size = size

func createSkeleton():
	container = VBoxContainer.new()
	#container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(container)
	container.owner = self
	
	var topBarContainer = HBoxContainer.new()
	container.name = _Container
	container.add_child(topBarContainer)
	topBarContainer.owner = container
	
	refreshButton = Button.new()
	refreshButton.name = _RefreshButton
	refreshButton.text = "Refresh"
	refreshButton.pressed.connect(update)
	topBarContainer.add_child(refreshButton)
	refreshButton.owner = topBarContainer
	
	backButton = Button.new()
	backButton.name = _BackButton
	backButton.text = "Back"
	backButton.pressed.connect(back)
	topBarContainer.add_child(backButton)
	backButton.owner = topBarContainer
	
	var placeBarContainer = HBoxContainer.new()
	topBarContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topBarContainer.add_child(placeBarContainer)
	placeBarContainer.owner = topBarContainer
	
	nodeNameButton = Button.new()
	nodeNameButton.name = _NodeNameButton
	placeBarContainer.add_child(nodeNameButton)
	nodeNameButton.owner = placeBarContainer
	
	deviceConnButton = Button.new()
	deviceConnButton.name = _DeviceConnButton
	placeBarContainer.add_child(deviceConnButton)
	deviceConnButton.owner = placeBarContainer
	
	registerNameLabel = Label.new()
	registerNameLabel.name = _RegisterNameLabel
	placeBarContainer.add_child(registerNameLabel)
	registerNameLabel.owner = placeBarContainer
	
	registerWidget = VBoxContainer.new()
	registerWidget.name = _RegisterWidget
	container.add_child(registerWidget)
	registerWidget.owner = container
	
	registerValueLabel = Label.new()
	registerValueLabel.name = _RegisterValueLabel
	registerWidget.add_child(registerValueLabel)
	registerValueLabel.owner = registerWidget
	
	var scroll = ScrollContainer.new()
	container.add_child(scroll)
	scroll.owner = container
	
	bottomList = VBoxContainer.new()
	bottomList.name = _BottomList
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(bottomList)
	bottomList.owner = scroll

func clearList():
	while bottomList.get_child_count():
		var item = bottomList.get_child(0)
		bottomList.remove_child(item)
		item.queue_free()

func clear():
	nodeNameButton.visible = false
	deviceConnButton.visible = false
	registerNameLabel.visible = false
	
	registerWidget.visible = false
	
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

func populateRegister():
	var baseNode = get_node(baseNodePath)
	var targetNode = get_node(targetNodePath)
	if baseNode == null or targetNode == null: return
	var val = baseNode.node_register_read(targetNode, targetDeviceConn, targetRegisterName)
	registerWidget.visible = true
	if val is String:
		registerValueLabel.text = val
	else:
		registerValueLabel.text = str(val)

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
	populateRegister()

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
	populateRegister()

func _init():
	size_changed.connect(onResize)
	if firstRun:
		createSkeleton()
		firstRun = false

#func _ready():
	#update()

func game_loaded():
	print("Inspector: Restoring")
	container = find_child(_Container) as VBoxContainer
	backButton = find_child(_BackButton) as Button
	refreshButton = find_child(_RefreshButton) as Button
	nodeNameButton = find_child(_NodeNameButton) as Button
	deviceConnButton = find_child(_DeviceConnButton) as Button
	registerNameLabel = find_child(_RegisterNameLabel) as Label
	bottomList = find_child(_BottomList) as VBoxContainer
	registerWidget = find_child(_RegisterWidget) as VBoxContainer
	registerValueLabel = find_child(_RegisterValueLabel)
