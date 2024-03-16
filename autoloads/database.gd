extends Node

const SAVE_PATH_ROOT = "user://"
const CARDS_PATH = "%s/cards/" % SAVE_PATH_ROOT
const DECKS_PATH = "%s/decks/" % SAVE_PATH_ROOT
const TEXTURE_PATH = "%s/textures/" % SAVE_PATH_ROOT

var network_queue = []

var data = {}

var file_dialog: FileDialog
var paths

signal file_dialog_end(path)

signal on_task_added(task)
signal on_task_popped(task)

# emitted when a new file is received via rpc
signal on_data_added(file_name: String)

# emitted when a new file is confirmed to be received via rpc
signal on_data_added_confirmed(file_name: String)

# emitted when a new file is confirmed to be received via rpc
signal on_data_exist_checked(xs)

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
    
    on_data_added.connect(func(file_name: String): 
        print(multiplayer.get_unique_id(), " got file: ", file_name))
    
    on_data_added_confirmed.connect(func(file_name: String): 
        print(multiplayer.get_unique_id(), " confirmed ", 
        multiplayer.get_remote_sender_id(), " got file: ", file_name))
    
    on_data_exist_checked.connect(func(xs):
        print(multiplayer.get_unique_id(), " checked ", 
        multiplayer.get_remote_sender_id(), " has file: ", xs[0], " is ", str(xs[1])))

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

func get_data(file_name: String, callback):
    if !Database.data.has(file_name):
        Database.request_file_from_sender.rpc_id(multiplayer.get_remote_sender_id(), file_name)
        var path = ""
        while path != file_name:
            path = await Database.on_data_added
    callback.call(Database.data[file_name])
    return Database.data[file_name]

###################### NETWORK QUEUE ########################
func queue_task(task: Callable):
    queue_tasks([task])

func queue_tasks(tasks):
    insert_tasks(tasks, network_queue.size())

func insert_task(task, index: int):
    insert_tasks([task], index)

func insert_tasks(tasks, index: int):
    if tasks.is_empty(): return

    var was_empty: bool = network_queue.is_empty()
    tasks.reverse()
    for t in tasks:
        network_queue.insert(index, t)
        on_task_added.emit(t)

    print(multiplayer.get_unique_id(), " inserted tasks ", tasks, " at ", str(index))
    if was_empty:
        print(multiplayer.get_unique_id(), " initiated network queue")
        network_queue[0].call()

func pop_task():
    print("pop task ", network_queue[0])    
    var popped = network_queue.pop_front()
    on_task_popped.emit(popped)
    
    if !network_queue.is_empty():
        print("execute next task ", network_queue[0])
        network_queue[0].call()

func task_file_sharing(file_name: String, bytes: PackedByteArray):
    for p in multiplayer.get_peers():
        insert_task(task_file_sending.bind(p, file_name, bytes), 1)
    insert_task(task_file_sending.bind(multiplayer.get_unique_id(), file_name, bytes), 1)
    pop_task()

# send the file to peer if the peer does not have the file
func task_file_sending(peer: int, file_name: String, bytes: PackedByteArray):
    if !data.has(file_name):
        add_data(file_name, bytes)
    
    if peer == multiplayer.get_unique_id():
        print("self has file ", file_name)
        pop_task()
        return

    print("checking if ", str(peer), " has file ", file_name)
    check_file.rpc_id(peer, file_name)
    var xs = await on_data_exist_checked
    var file_exist: bool = xs[1]
    if !file_exist:
        print("sending file ", file_name ," to ", str(peer))
        send_file.rpc_id(peer, file_name, bytes)
        await on_data_added_confirmed
    
    pop_task()

# tell server to spawn object
# should be called after checking the server has the corresponding files
func task_new_object(front: String, back: String, pos: Vector2, count: int = 1):
    DragDropServer.new_object.rpc(PackedStringArray([front, back]), pos, count)
    DragDropServer.new_object(PackedStringArray([front, back]), pos, count)
    pop_task()

# should be called after checking the server has the corresponding files
func task_new_object_for_peer(peer: int, front: String, back: String, pos: Vector2, count: int = 1):
    DragDropServer.new_object.rpc_id(peer, PackedStringArray([front, back]), pos, count)
    pop_task()

######################## RPC ################################

@rpc("any_peer", "call_remote", "reliable")
func check_file(file_name: String):
    return_check_file.rpc_id(
        multiplayer.get_remote_sender_id(), file_name, data.has(file_name))

@rpc("any_peer", "call_remote", "reliable")
func return_check_file(file_name: String, exist: bool):
    on_data_exist_checked.emit([file_name, exist])

@rpc("any_peer", "call_remote", "reliable")
func confirm_file(file_name: String):
    on_data_added_confirmed.emit(file_name)

@rpc("any_peer", "call_remote", "reliable")
func send_file(file_name: String, bytes: PackedByteArray):
    if !data.has(file_name):
        print(multiplayer.get_unique_id(), " got file ", file_name)
        add_data(file_name, bytes)
        on_data_added.emit(file_name)
        confirm_file.rpc_id(multiplayer.get_remote_sender_id(), file_name)

@rpc("any_peer", "call_remote", "reliable")
func request_file_from_sender(file_name: String):
    if data.has(file_name):
        print(multiplayer.get_unique_id(), " got request ", file_name)
        send_file.rpc_id(multiplayer.get_remote_sender_id(), file_name, data[file_name])         
