extends Control

var deck: Dictionary

@export var card_selection: Control
@export var deck_display: RichTextLabel
@export var save_btn: Button
@export var load_btn: Button
var file_dialog: FileDialog

signal on_deck_changed

func _ready():
    file_dialog = FileDialog.new()
    file_dialog.access = FileDialog.ACCESS_USERDATA
    file_dialog.filters = ["*.tres"]
    file_dialog.size = Vector2(300, 400)
    add_child(file_dialog)
    
    save_btn.pressed.connect(save_deck)
    load_btn.pressed.connect(load_deck)
    card_selection.on_card_clicked.connect(card_clicked)
    deck_display.meta_clicked.connect(remove_one)
    on_deck_changed.connect(update_deck_display)
    on_deck_changed.connect(func(): print(deck))

func card_clicked(path: String):
    if Input.is_action_just_released("LMB"):
        add_one(path)

func update_deck_display():
    if len(deck) == 0:
        deck_display.text = ""
        return
    
    var img = Image.new()
    img.load(deck.keys()[0])
    var img_size = ImageTexture.create_from_image(img).get_size() * card_selection.IMG_SCALE
    var img_size_text = "%dx%d" % [img_size.x, img_size.y]
    deck_display.text = ""
    for k in deck.keys():
        deck_display.text += "[url=%s][img=%s]%s[/img][/url]x%d" % [k, img_size_text, k, deck[k]]

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
    file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
    file_dialog.popup_centered()
    var path = await file_dialog.file_selected
    print(path)
    if len(deck) > 0:
        Database.save_file(generate_deck(), path)

func load_deck():
    file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    file_dialog.popup_centered()
    var path = await file_dialog.file_selected
    var res = Database.load_file(path)
    if res is DeckRes:
        deck = res.cards_dict
        on_deck_changed.emit()

func generate_deck() -> DeckRes:
    var res = DeckRes.new()
    res.cards_dict = deck
    return res
