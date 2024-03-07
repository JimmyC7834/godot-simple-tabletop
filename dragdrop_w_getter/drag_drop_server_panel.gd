extends Node2D

const DRAG_DROP_CURSOR = preload("res://dragdrop_w_getter/drag_drop_cursor.tscn")

@onready var lobby_ui: Lobby = $LobbyUI

func _ready():
    lobby_ui.on_player_added.connect(add_client_cursor)
    lobby_ui.on_server_created.connect(add_client_cursor)

func add_client_cursor(id: int = 1):
    var inst = DRAG_DROP_CURSOR.instantiate()
    inst.name = str(id)
    add_child(inst)
