class_name CardSelectionScreen
extends Panel

const IMG_SCALE: float = 0.5
const FOCUS_HOVER_SPAN: float = 1.0

@export var item_list: ItemList
@export var card_display: TextureRect
@export var sort_btn: Button
@export var import_btn: Button

var hovering: bool = false
var card_paths: Array = []

signal on_card_clicked(path: String, mouse_idx: int)

func _ready():
    item_list.item_clicked.connect(func(id: int, _pos, mouse_idx: int):
        on_card_clicked.emit(card_paths[id], mouse_idx))

    import_btn.pressed.connect(func():
        var paths = Database.choose_path(
            FileDialog.FILE_MODE_OPEN_FILES, ["*.png, *.jpg, *.jpeg"])
        print(paths)
        if paths == null:
            return
        card_paths.append_array(Array(paths))
        update_cards_display()
        )
    
    sort_btn.pressed.connect(func():
        card_paths.sort()
        update_cards_display()
        )

func update_cards_display():
    var uni: Array = []
    for a in card_paths:
        if not a in uni:
            uni.append(a)
    card_paths = uni
    
    item_list.clear()
    item_list.fixed_icon_size = ((item_list.size.x / item_list.max_columns)) * Vector2.ONE
    if len(card_paths) == 0: return
    
    var img_size = Utils.get_texture_by_path(card_paths[0]).get_size() * IMG_SCALE

    var i = 0
    for p in card_paths:
        var t: Texture2D = Utils.get_texture_by_path(p)
        item_list.add_icon_item(t)
        i += 1
