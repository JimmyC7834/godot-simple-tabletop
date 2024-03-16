extends Node

const DRAG_DROP_CURSOR = preload("res://dragdrop_w_getter/drag_drop_cursor.tscn")

@export var lobby_ui: Lobby
@export var menubar: Control
@export var deckbuilder: Window
@export var card_preview: Window

func _ready():
    #lobby_ui.on_player_added.connect(DragDropServer.clear_all_card.unbind(1))
    lobby_ui.on_player_added.connect(add_client_cursor)
    lobby_ui.on_server_created.connect(add_client_cursor)
    
    lobby_ui.on_server_created.connect(lobby_ui.hide)
    lobby_ui.on_server_created.connect(menubar.show)
    lobby_ui.on_client_created.connect(lobby_ui.hide)
    lobby_ui.on_client_created.connect(menubar.show)
    
    menubar.on_item_clicked.connect(
        func(id: int):
            if id == menubar.DECK_BUILDER:
                deckbuilder.show()
            elif id == menubar.CARD_PREVIEW:
                card_preview.show()
            elif id == menubar.LOGIN_SCREEN:
                lobby_ui.show()
    )    
    
func add_client_cursor(id: int = 1):
    print("client added: ", str(id))
    var inst = DRAG_DROP_CURSOR.instantiate()
    inst.name = str(id)
    add_child(inst)
    
    #for c in DragDropServer.cards:
        #Database.queue_tasks([
            #Database.task_file_sending.bind(id, c.file_names[0], Database.data[c.file_names[0]]),
            #Database.task_file_sending.bind(id, c.file_names[1], Database.data[c.file_names[1]]),
            #Database.task_new_object_for_peer.bind(id, c.file_names[0], c.file_names[1], c.global_position),
        #])
