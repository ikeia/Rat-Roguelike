extends Node

var save_dir = "user://saves"
var save_ext = "game.tres"
var things_to_save = []
export(bool) var debug = true

var save_file:Script = load("res://Save_File.gd")

func _ready():
	var dir = Directory.new()
	if !dir.dir_exists(save_dir):
		if debug:
			print("Initializing Saves Directory")
		dir.make_dir(save_dir)



func detect_data(scene):
	#var data = []
	#for stuff in things_to_save:
		#data += stuff.get_nodes_in_group("Persist")
	var data = scene.get_tree().get_nodes_in_group("Persist")
	return data
	
func save_current_scene(file_num=0,tree=null):
	if file_num == null:
		printerr("No File Selected")
		return
	file_num = String(file_num)
	if debug:
		print("Save file Directory ",file_num," is selected")
	var file_location = save_dir+"/"+file_num
	var dir = Directory.new()
	var save_game = File.new()

	if !dir.dir_exists(file_location):
		if debug:
			print("Creating new save instance")
		dir.make_dir(file_location)

	if save_game.file_exists(file_location+"/"+save_ext):
		if debug:
			print('Save data exsists')
		var confirm = ConfirmationDialog.new()
		confirm.window_title = "Overwrite Exsisting Data?"
		tree.add_child(confirm)
		confirm.popup()
		yield(confirm,"confirmed")
		if debug:
			print('OVERWRITING EXISITING DATA')
	elif debug:
		print("New Save data Created")
	save_game.open(file_location+"/"+save_ext, File.WRITE)

	var save_nodes = detect_data(tree)
	var save = save_file.new()
	
	if debug:
		print("detecting data...")
	for node in save_nodes:
		if debug:
			print("... Attempting save on: ",node.name)
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			if debug:
				print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			if debug:
				print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		print(node.name," is saved")

		for i in node_data.keys():
			if i == "file_name" or i == "parent":
				continue
			#save.set(i, node_data[i])
			print(save.get(i)," ... checking for ", i)
			if save.get(i) != null:
				save[i] = node_data[i]
				print("Writing data... ",i)

		# Store the save dictionary as a new line in the save file.
		#save_game.store_line(to_json(node_data))
	
	ResourceSaver.save(file_location+"/"+save_ext,save)
	if debug:
		if save_nodes.size() == 0:
			print("No Nodes saved")
		else:
			print("Saved ",save_nodes.size()," Nodes")
	save_game.close()


func load_game(file_num=0,tree=null):
	print("Loading")
	var save_game = File.new()
	if file_num == null:
		printerr("No File Selected")
		return
	var file_location = save_dir+"/"+file_num+"/"+save_ext
	if not save_game.file_exists(file_location):
		printerr("ERROR save ",file_num," does not exist at path: ",file_location)
		return
	var confirm = ConfirmationDialog.new()
	confirm.window_title = "Load Game? Any currently unsaved progress will be lost."
	tree.add_child(confirm)
	confirm.popup()
	yield(confirm,"confirmed")
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = detect_data(tree)
	for i in save_nodes:
		i.queue_free()
		#i.despawn()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open(file_location, File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		#var node_data = parse_json(save_game.get_line())
		var node_data = load(file_location)

		# Firstly, we need to create the object and add it to the tree and set its position.
		#var new_object = load(node_data["file_name"]).instance()
		var new_object = load("res://Player/Player_Controller.tscn").instance()
		#new_object.global_position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		get_node(node_data["parent"]).add_child(new_object)
		if new_object.is_in_group("Player"):
			#new_object.sword_pos = Vector2(node_data["sword_pos_x"], node_data["sword_pos_y"])
			#new_object.tail_length = node_data["tail_length"]
			pass

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "file_name" or i == "parent":
				continue
			new_object.set(i, node_data[i])

	save_game.close()	
	
func delete_save(file_num=0,tree=null):
	file_num = String(file_num)
	if debug:
		print("Save file Directory ",file_num," is selected")
	var file_location = save_dir+"/"+file_num
	var dir = Directory.new()
	var save_game = File.new()
	
	if !dir.dir_exists(file_location):
		printerr("File selected: ",file_location," does not exsist")
		return
	
	else:
		if debug:
			print('Save data exsists')
		var confirm = ConfirmationDialog.new()
		confirm.window_title = "Delete Save Data?"
		tree.add_child(confirm)
		confirm.popup()
		yield(confirm,"confirmed")
		if debug:
			print('DELETING EXISITING DATA')
	dir.remove(file_location+"/"+save_ext)
	dir.remove(file_location)
	tree.update()
	

