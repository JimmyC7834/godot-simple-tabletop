extends Node

const DRAG_DROP_CURSOR = preload("res://dragdrop_w_getter/drag_drop_cursor.tscn")

@export var lobby_ui: Lobby
@export var menubar: Control
@export var deckbuilder: Window

func _ready():
    lobby_ui.on_player_added.connect(DragDropServer.clear_all_card.unbind(1))
    lobby_ui.on_player_added.connect(add_client_cursor)
    lobby_ui.on_server_created.connect(add_client_cursor)
    lobby_ui.on_client_created.connect(lobby_ui.queue_free)
    
    menubar.on_item_clicked.connect(
        func(id: int):
            if id == 0:
                deckbuilder.show()
            elif id == 1:
                lobby_ui.show()
    )    
    
func add_client_cursor(id: int = 1):
    print("client added: ", str(id))
    var inst = DRAG_DROP_CURSOR.instantiate()
    inst.name = str(id)
    add_child(inst)
    lobby_ui.hide()
    menubar.show()
