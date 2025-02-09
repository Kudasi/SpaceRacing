extends MultiplayerSpawner

@export var map_scene : PackedScene
@export var player_scene : PackedScene

func _ready() -> void:
	if multiplayer.is_server():
		load_scene.rpc(map_scene)
		
@rpc("authority","call_remote","reliable")
func load_scene(packed_scene : PackedScene):
	var scene = packed_scene.instantiate()
	add_sibling(scene)


func create_player():
	pass
	
