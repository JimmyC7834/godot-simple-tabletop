extends Node

const DRAG_DROP_CURSOR = preload("res://dragdrop_w_getter/drag_drop_cursor.tscn")
const DRAG_DROP_SERVER_PANEL = preload("res://ui/drag_drop_server_panel.tscn")

@export var lobby_ui: Lobby
@onready var game_ui = $GameUI

func _ready():
    game_ui.hide()
    
    lobby_ui.on_player_added.connect(add_client_cursor)
    lobby_ui.on_player_added.connect(DragDropServer.clear_all_card.unbind(1))
    lobby_ui.on_server_created.connect(add_client_cursor)

func initiate_game(id: int = 1):
    get_tree().root.add_child(DRAG_DROP_SERVER_PANEL.instantiate())
    add_client_cursor(id)    
    
func add_client_cursor(id: int = 1):
    var inst = DRAG_DROP_CURSOR.instantiate()
    inst.name = str(id)
    get_tree().root.add_child(inst)
    game_ui.show()    
    lobby_ui.queue_free()
    #add_child(inst)
