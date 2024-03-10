extends Control

var deck: Dictionary
var card_textures: Dictionary

@export var card_selection: CardSelectionScreen
@export var deck_display: ItemList
@export var save_btn: Button
@export var load_btn: Button

signal on_deck_changed

func _ready():
    deck_display.icon_mode = ItemList.ICON_MODE_TOP    
    
    save_btn.pressed.connect(save_deck)
    load_btn.pressed.connect(load_deck)
    
    card_selection.on_card_clicked.connect(card_clicked)
    
    deck_display.item_clicked.connect(
        func(id: int, _pos, mouse_idx: int):
            card_clicked(deck.keys()[id], mouse_idx)
    )
    
    on_deck_changed.connect(update_deck_display)
    on_deck_changed.connect(func(): print(deck))

func card_clicked(path: String, mouse_idx: int):
    if mouse_idx == MOUSE_BUTTON_LEFT:
        add_one(path)
    elif mouse_idx == MOUSE_BUTTON_RIGHT:
        remove_one(path)

func update_deck_display():
    deck_display.fixed_icon_size = ((deck_display.size.x / deck_display.max_columns) - 25) * Vector2.ONE
    deck_display.clear()
    var i = 0
    for key in deck:
        deck_display.add_icon_item(Utils.get_texture_by_path(key))
        deck_display.set_item_text(i, str(deck[key]))
        i += 1

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
        on_deck_changed.emit()

func generate_deck() -> DeckRes:
    var res = DeckRes.new()
    res.cards_dict = deck
    for key in deck:
        var img = Image.load_from_file(key)
        img.compress(Image.COMPRESS_ASTC, Image.COMPRESS_SOURCE_GENERIC, Image.ASTC_FORMAT_8x8)
        res.card_textures[key] = img
    return res
