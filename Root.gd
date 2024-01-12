extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var scene_halted = true
var scene_already_paused = false
var path_to_load

const TestSaveSlot = "TestSaveSlot"
const SaveSlotPrefix = "user://saves/"
const SaveFlags = ResourceSaver.FLAG_BUNDLE_RESOURCES | ResourceSaver.FLAG_CHANGE_PATH

# Called when the node enters the scene tree for the first time.

#func getSaveSlotDirectory(slot):
#	return SaveSlotPrefix + slot + "/"
#
#func getSaveSlotScenePath(slot):
#	return getSaveSlotDirectory(slot) + "main.tscn"

func getMenuRoot():
	return get_node("MenuRoot") as CenterContainer

func getSaveFileConfirmDialog() -> ConfirmationDialog:
	return get_node("MMenu/SaveFileDialog/@@151") as ConfirmationDialog
	

func getMainMenu():
	return get_node("MenuRoot/MainMenu") as VBoxContainer

func getNewGameMenu():
	return get_node("MenuRoot/NewGameMenu") as VBoxContainer

#func hasActiveRuntime():
#	return (get_node("Loaded").get_child_count() > 0)

func isSceneLoaded() -> bool:
	return get_node("Loaded").get_child_count() > 0

func getLoadedScene() -> Node:
	if isSceneLoaded():
		return get_node("Loaded").get_child(0)
	return null

func attatchLoadedScene(scene):
	var ln = get_node("Loaded")
	ln.add_child(scene)
	scene.set_owner(ln)
	print("Attatch scene: loaded node childs: ", ln.get_child_count())

func detatchLoadedScene(del):
	if not isSceneLoaded():
		print("Cannot detatch scene - not loaded!")
		return null
	var ln = get_node("Loaded")
	var scene = getLoadedScene()
	ln.remove_child(scene)
	print("Detatch scene: loaded node childs: ", ln.get_child_count())
	if scene.get_owner() != null: print("Scene owner still not null!")
	if del: scene.queue_free()

func isSceneHalted():
	if scene_halted and not get_tree().paused:
		print("Scene halted but not paused???")
	return get_tree().paused and scene_halted

func haltScene():
#	if not isSceneLoaded(): return false
	if scene_halted: print("Scene already halted!")
	scene_halted = true
	if get_tree().paused: scene_already_paused = true
	else: get_tree().paused = true
	getMenuRoot().visible = true
	if isSceneLoaded():
		getMainMenu().get_node("ButtonContinue").visible = true
	else:
		getMainMenu().get_node("ButtonContinue").visible = false
#	return true

func resumeScene():
	print("resumeScene()")
#	if not isSceneLoaded(): return false
	if not scene_halted:
		print("Scene not halted!")
		return false
	if scene_already_paused and not get_tree().paused:
		print("Scene already paused but not really paused???")
	if not scene_already_paused:
		get_tree().paused = false
	scene_halted = false
	getMenuRoot().visible = false
	
	return true

func loadFromFileDialog():
	var dialog = getMenuRoot().get_node("OpenFileDialog")
	if dialog == null:
		print("No open file dialog found!!")
		return
	dialog.invalidate()
	dialog.popup_centered()

func onLoadFromFileAccepted():
	print("Prepare save file loading...")
	var dialog = getMenuRoot().get_node("OpenFileDialog")
	if dialog == null:
		print("No open file dialog found!!")
		return
	var path = dialog.get_current_path()
#	var file = dialog.get_current_file()
#	var dir = dialog.get_current_dir()
#	print(path)
#	print(file)
#	print(dir)
	if doLoadFromFile(path):
		print("File loaded, resuming...")
		resumeScene()

func doLoadFromFile(path):
	var ps = load(path)
	if ps == null:
		print("Loaded scene is null!")
		return false
	detatchLoadedScene(true)
	var scene = ps.instantiate()
#	get_node("Loaded").add_child(scene)
	attatchLoadedScene(scene)
	return true

#func doLoadFromFileDelayed(path):
#	self.path_to_load = path
#	return true

func saveToFileDialog():
	var dialog = getMenuRoot().get_node("SaveFileDialog")
	if dialog == null:
		print("No save file dialog found!!")
		return
	dialog.invalidate()
	dialog.popup_centered()
	

func onCustomAction(aname):
	print("Called custom action: " + aname)

func onSaveToFileAccepted():
	print("Save dialog accepted")
	var dialog = getMenuRoot().get_node("SaveFileDialog")
	if dialog == null:
		print("No save file dialog found!!")
		return
#	var cd = getSaveFileConfirmDialog()
#	if cd == null:
#		print("No confirm sub-dialog!")
#	print("Is confirm dialog visible:", cd.visible)
#	if cd.visible:
#		print("Wait for extra confirmation...")
#		dialog.invalidate()
#		return
	var path = dialog.get_current_path()
#	var file = dialog.get_current_file()
#	var dir = dialog.get_current_dir()
#	print(path)
#	print(file)
#	print(dir)
	doSaveToFile(path)
	dialog.invalidate()

func doSaveToFile(path : String):
	print("Saving scene to path: %s" % path)
	var scene = getLoadedScene()
	if scene == null:
		print("No scene loaded, what do you want to save??!")
		return false
	var ps = PackedScene.new()
	ps.pack(scene)
#	var err = ResourceSaver.save(ps, path, SaveFlags)
	var err = ResourceSaver.save(ps, path)
	if err:
		print("Error while saving scene:")
		print(err)
	return true


func doLoadNewNamed(gname):
	print("Loading " + gname)
	var path = "res://NewGames/" + gname + ".tscn"
	detatchLoadedScene(true)
	var ps = load(path)
	var scene = ps.instantiate()
	attatchLoadedScene(scene)
	enterMainMenu()
	resumeScene()

#func doLoadNew():
#	detatchLoadedScene(true)
#	var ps = load("res://NewGames/DefaultNew.tscn")
#	var scene = ps.instantiate()
#	attatchLoadedScene(scene)
#	enterMainMenu()
#	resumeScene()

func addNewGameButton(gamename : String):
	var b = NamedButton.new()
	b.text = gamename
	b.pressed_name.connect(doLoadNewNamed)
	var c = getNewGameMenu()
	c.add_child(b)

func enterNewGamesMenu():
	print("Entering new game menu.")
	var mm = getMainMenu()
	var ngm = getNewGameMenu()
	mm.visible = false
	ngm.visible = true

func enterMainMenu():
	print("Entering root menu.")
	var mm = getMainMenu()
	var ngm = getNewGameMenu()
	mm.visible = true
	ngm.visible = false

func quit():
	get_tree().quit()
	pass # Replace with function body.

func _ready():
	addNewGameButton("DefaultNew")
	addNewGameButton("DefaultNew2")
#	var cd = getSaveFileConfirmDialog()
#	if cd == null:
#		print("Cannot find save confirmation sub-dialog")
#		return
#	cd.connect("confirmed", Callable(self, "onSaveToFileAccepted"))
	pass # Replace with function body.
#	doLoadNew()
	Globals.test_global_variable = "Hejka!"
	print("Root scene ready.")

func _input(event):
	if event.is_action("ui_cancel") and isSceneLoaded():
		haltScene()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#	if self.path_to_load:
#		doLoadFromFile(self.path_to_load)
#		self.path_to_load = null
#		pass
	pass
