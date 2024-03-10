extends MenuBar

@onready var options: PopupMenu = $Options

signal on_item_clicked(id: int)

func _ready():
    options.id_pressed.connect(func(id): on_item_clicked.emit(id))
