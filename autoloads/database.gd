extends Node

const SAVE_PATH_ROOT = "user://"
const CARDS_PATH = "%s/cards/" % SAVE_PATH_ROOT
const DECKS_PATH = "%s/decks/" % SAVE_PATH_ROOT
const TEXTURE_PATH = "%s/textures/" % SAVE_PATH_ROOT

var data = {}

var file_dialog: FileDialog
var paths

signal file_dialog_end(path)
signal on_data_added(file_name: String)

func _ready():
    DirAccess.make_dir_absolute(SAVE_PATH_ROOT)
    DirAccess.make_dir_absolute(CARDS_PATH)
    DirAccess.make_dir_absolute(DECKS_PATH)
    DirAccess.make_dir_absolute(TEXTURE_PATH)
    
    file_dialog = FileDialog.new()
    file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    file_dialog.use_native_dialog = true
    file_dialog.size = Vector2(400, 600)
    add_child(file_dialog)
    
    file_dialog.file_selected.connect(func(path): file_dialog_end.emit(path))
    file_dialog.files_selected.connect(func(path): paths = path)
    file_dialog.dir_selected.connect(func(path): print(path))
    file_dialog.canceled.connect(func(): file_dialog_end.emit(null))
    file_dialog.confirmed.connect(func(): file_dialog_end.emit(null))

func choose_path(file_mode: FileDialog.FileMode, filter: Array[String] = ["*.tres"]):
    file_dialog.file_mode = file_mode
    file_dialog.filters = filter
    file_dialog.popup_centered()

    var path
    if file_mode == FileDialog.FILE_MODE_OPEN_FILES:
        path = paths
    else:
        path = file_dialog.current_file
    
    print("path: ", path)
    return null if path is String and path == "" else path

func save_file(res: Resource, path: String, file_name: String = ""):
    ResourceSaver.save(res, path + file_name)

func load_file(path: String, file_name: String = "") -> Resource:
    return ResourceLoader.load(path + file_name)

func file_name_from_path(path: String) -> String:
    var packed_arr: PackedStringArray = path.split("\\")
    return packed_arr[packed_arr.size() - 1]

func add_data(file_name: String, bytes: PackedByteArray):
    data[file_name] = bytes    

func get_data(file_name: String, bytes: PackedByteArray):
    if !Database.data.has(file_name):
        Database.request_file_from_peer.rpc_id(multiplayer.get_remote_sender_id(), file_name)
        var path = ""
        while path != file_name:
            path = await Database.on_data_added
    return Database.data[file_name]

@rpc("any_peer", "call_local", "reliable")
func share_file(file_name: String, bytes: PackedByteArray):
    if !data.has(file_name):
        add_data(file_name, bytes)
        on_data_added.emit(file_name)

@rpc("any_peer", "call_remote", "reliable")
func request_file_from_peer(file_name: String):
    if data.has(file_name):
        share_file.rpc_id(multiplayer.get_remote_sender_id(), file_name, data[file_name])         
