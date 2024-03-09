class_name CardCollectionRes
extends Resource

@export var cards: Array[Texture2D]

func get_paths() -> Array[String]:
    var paths: Array[String] = []
    for c in cards:
        paths.append(c.resource_path)
    return paths
