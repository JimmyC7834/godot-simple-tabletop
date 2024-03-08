extends Node

const SAVE_PATH_ROOT = "user://"
const CARDS_PATH = "%s/cards/" % SAVE_PATH_ROOT
const DECKS_PATH = "%s/decks/" % SAVE_PATH_ROOT

func _ready():
    DirAccess.make_dir_absolute(SAVE_PATH_ROOT)
    DirAccess.make_dir_absolute(CARDS_PATH)
    DirAccess.make_dir_absolute(DECKS_PATH)

func save_file(res: Resource, path: String, file_name: String = ""):
    ResourceSaver.save(res, path + file_name)

func load_file(path: String, file_name: String = "") -> Resource:
    return ResourceLoader.load(path + file_name)
