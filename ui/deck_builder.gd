extends Window

var deck: Dictionary
var card_textures: Dictionary

@export var card_selection: CardSelectionScreen
@export var deck_display: ItemList
@export var save_btn: Button
@export var load_btn: Button
@export var label: Label

var card_back_path: String = ""

signal on_deck_changed

func _ready():
    deck_display.icon_mode = ItemList.ICON_MODE_TOP
    
    save_btn.pressed.connect(save_deck)
    load_btn.pressed.connect(load_deck)
    
    card_selection.on_card_clicked.connect(card_clicked)
    
    deck_display.item_clicked.connect(
        func(id: int, _pos, mouse_idx: int):
            # only takes left and right click
            if not mouse_idx in [0, 1]: return
            
            if id == 0:
                var path = Database.choose_path(
                    FileDialog.FILE_MODE_OPEN_FILE,  
                    ["*.png", "*.jpg", "*.jpeg"])
                if path != null:
                    card_back_path = path
                update_deck_display()
            else:
                card_clicked(deck.keys()[id - 1], mouse_idx))
    
    on_deck_changed.connect(update_deck_display)
    on_deck_changed.connect(func(): print(deck))
    
    close_requested.connect(hide)
    
    update_deck_display()

func card_clicked(path: String, mouse_idx: int):
    if mouse_idx == MOUSE_BUTTON_LEFT:
        add_one(path)
    elif mouse_idx == MOUSE_BUTTON_RIGHT:
        remove_one(path)

func update_deck_display():
    deck_display.fixed_icon_size = ((deck_display.size.x / deck_display.max_columns) - 25) * Vector2.ONE
    deck_display.clear()
    add_card_back_item()

    var count = 0
    for key in deck:
        var i = deck_display.add_icon_item(Utils.get_texture_by_path(key))
        deck_display.set_item_text(i, str(deck[key]))
        count += deck[key]

    label.text = "Deck Card Count: %d" % count

func add_card_back_item():
    if card_back_path == "":
        deck_display.add_item("Card Back")
    else:
        var i = deck_display.add_icon_item(Utils.get_texture_by_path(card_back_path))
        assert(i == 0)
        deck_display.set_item_text(i, "Card Back")        

func add_one(path: String):
    if !deck.has(path):
        deck[path] = 0

    deck[path] += 1
    on_deck_changed.emit()

func remove_one(path: String):
    if !deck.has(path): return
    deck[path] -= 1
    
    if deck[path] == 0:
        deck.erase(path)

    on_deck_changed.emit()

func save_deck():
    var path = Database.choose_path(FileDialog.FILE_MODE_SAVE_FILE)
    if path == null:
        return

    if len(deck) > 0:
        Database.save_file(generate_deck(), path)

func load_deck():
    var path = Database.choose_path(FileDialog.FILE_MODE_OPEN_FILE)
    if path == null:
        return
        
    var res = Database.load_file(path)
    if res is DeckRes:
        deck = res.cards_dict
        card_textures = res.card_textures
        card_back_path = res.back_texture_path
        on_deck_changed.emit()

func generate_deck() -> DeckRes:
    var res = DeckRes.new()
    res.cards_dict = deck
    res.back_texture_path = card_back_path
    res.back_texture_base64 = Utils.read_file_as_base64(card_back_path)
    for key in deck:
        res.card_textures[key] = Utils.read_file_as_base64(key)
    return res
