extends Node2D

func goto_scene(path):
    # remove current scene
    get_tree().current_scene.queue_free()
    print("FREED SCENE")
    yield(get_tree().current_scene, "tree_exited")
    # instance new scene
    get_tree().change_scene(path)