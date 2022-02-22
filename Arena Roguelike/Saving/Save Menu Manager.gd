extends Control

onready var save_file_button = preload("res://Saving/save_file.tscn")
var files = []
var selected_file = null
var max_amount_of_save_files = 10
var current_amount_of_save_files = 0
export(String,"save","load") var mode = "save"


func _ready():
	$Save_Manip.visible = false
	update()
	
func update():
	for child in $Saves.get_children():
		child.queue_free()
	files = []
	var saves = Directory.new()
	if saves.open("user://saves") == OK:
		saves.list_dir_begin(true)
		for i in range(max_amount_of_save_files):
			var f = saves.get_next()
			if f != "":
				files.append(f)
			else:
				break
		print(files)
		current_amount_of_save_files = files.size()
		for i in range(current_amount_of_save_files):
			var save = save_file_button.instance()
			#save.rect_min_size = Vector2(128,52)
			save.text = files[i]
			$Saves.add_child(save)
		$Save_Manip.visible = true
	else:
		printerr("NO dir")
		$Save_Manip.visible = false

func reset_selected():
	for child in $Saves.get_children():
		child.pressed = false


func _on_create_pressed():
	$PopupMenu/LineEdit.placeholder_text = "Save "+String(current_amount_of_save_files)
	$PopupMenu.popup()

func _on_save_pressed():
	data.save_current_scene(selected_file,self)


func _on_load_pressed():
	data.load_game(selected_file,self)


func _on_delete_pressed():
	data.delete_save(selected_file,self)
	


func _on_LineEdit_text_entered(new_text):
	$PopupMenu.hide()
	if $PopupMenu/LineEdit.text != "":
		data.save_current_scene($PopupMenu/LineEdit.text,self)
		$PopupMenu/LineEdit.text = ""
	else:
		printerr("***Invalid Save Name")
	update()
