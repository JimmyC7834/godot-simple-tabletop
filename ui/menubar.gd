extends MenuBar

const DECK_BUILDER: int = 0
const CARD_PREVIEW: int = 1
const LOGIN_SCREEN: int = 99

@onready var options: PopupMenu = $Options

signal on_item_clicked(id: int)

func _ready():
    options.id_pressed.connect(func(id): on_item_clicked.emit(id))
