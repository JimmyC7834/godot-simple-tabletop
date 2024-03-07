extends Node

func delay(t: float):
    return get_tree().create_timer(t)
