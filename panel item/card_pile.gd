class_name CardPile
extends DragDropObject

@export var card_paths: Array[String]

func click():
    if can_click:
        _click.rpc()

@rpc("any_peer", "call_local", "reliable")
func _click():
    if multiplayer.is_server():
        # only server draw card
        if card_paths.size() > 0:
            draw_card()
            print("server draw card")

func draw_card() -> String:
    var path = card_paths.pick_random()
    # after draw inform clients
    _return_draw_card.rpc(path)
    return path

@rpc("authority", "call_remote", "reliable")
func _return_draw_card(path: String):
    # spawn the card and remove from pile    
    DragDropServer.new_card.rpc(path, global_position)
    card_paths.erase(path)

func load_deck(res: DeckRes):
    texture = res.back_texture
    for path in res.cards_dict:
        for i in range(res.cards_dict[path]):
            card_paths.append(path)
