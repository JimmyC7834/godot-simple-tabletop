extends Node

const SAVE_PATH_ROOT = "user://"
const CARDS_PATH = "%s/cards/" % SAVE_PATH_ROOT
const DECKS_PATH = "%s/decks/" % SAVE_PATH_ROOT
const TEXTURE_PATH = "%s/textures/" % SAVE_PATH_ROOT

var file_dialog: FileDialog

func _ready():
    DirAccess.make_dir_absolute(SAVE_PATH_ROOT)
    DirAccess.make_dir_absolute(CARDS_PATH)
    DirAccess.make_dir_absolute(DECKS_PATH)
    DirAccess.make_dir_absolute(TEXTURE_PATH)
    
    file_dialog = FileDialog.new()
    file_dialog.access = FileDialog.ACCESS_USERDATA
    file_dialog.filters = ["*.tres"]
    file_dialog.size = Vector2(400, 600)
    add_child(file_dialog)

func choose_path(file_mode: FileDialog.FileMode):
    file_dialog.popup_centered()
    return await file_dialog.file_selected

func save_file(res: Resource, path: String, file_name: String = ""):
    ResourceSaver.save(res, path + file_name)

func load_file(path: String, file_name: String = "") -> Resource:
    return ResourceLoader.load(path + file_name)
