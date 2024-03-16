extends Panel

@onready var progress_bar = $ProgressBar
var popped_count: int = 0

func _ready():
    Database.on_task_added.connect(update_progress)
    Database.on_task_popped.connect(func(_t): popped_count += 1)
    Database.on_task_popped.connect(update_progress)

func update_progress(_task):
    if Database.network_queue.is_empty():
        popped_count = 0
        hide()
    else:
        show()
        progress_bar.value = popped_count * 100.0 / (Database.network_queue.size() + popped_count)
