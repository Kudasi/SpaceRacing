extends PanelContainer

## Scene which will be set active on all peers when host press 'Start' button.
@export var start_scene : PackedScene

@export var scene_spawn : Node

var glider_list_data : Array[Dictionary] = [] 

func _ready() -> void:
	MultiplayerManager.player_connected.connect(_update_player_list)
	MultiplayerManager.player_disconnected.connect(_update_player_list)
	MultiplayerManager.server_disconnected.connect(_disconnected_from_server)
	
	var glider_index := 0
	for glider_path in DirAccess.get_files_at("res://gliders"):
		var glider : Node = load("res://gliders/" + glider_path).instantiate()
		
		glider_list_data[glider_index].display_name = glider.get_meta(&"display_name", "[unknown]")
		glider_list_data[glider_index].display_speed = glider.get_meta(&"display_speed", -1)
		glider_list_data[glider_index].display_maneurity = glider.get_meta(&"display_maneurity", -1)
		glider_list_data[glider_index].display_attack = glider.get_meta(&"display_attack", -1)
		glider_list_data[glider_index].skill_name = glider.get_meta(&"skill_name", "[unknown]")
		glider_list_data[glider_index].skill_desc = glider.get_meta(&"skill_desc", null)
		
		3
	
func _update_player_list(a, b=null):
	%PlayersList.clear()
	for player in MultiplayerManager.players:
		%PlayersList.add_item(MultiplayerManager.players[player].name)
	print(multiplayer.multiplayer_peer.get_unique_id(), MultiplayerManager.players)

func _disconnected_from_server():
	$Setup.visible = true
	$PlayersList.visible = false	

func _on_host_button_pressed() -> void:
	%KickButton.disabled = false
	%StartButton.disabled = false
	$Setup.visible = false
	$PlayersList.visible = true
	
	MultiplayerManager.player_info.name = %Nickname.text
	MultiplayerManager.host_server()

func _on_connect_button_pressed() -> void:
	%KickButton.disabled = true
	%StartButton.disabled = true
	$Setup.visible = false
	$PlayersList.visible = true
	
	MultiplayerManager.player_info.name = %Nickname.text
	MultiplayerManager.join_server(%IPAddres.text)


func _on_kick_button_pressed() -> void:
	for player in MultiplayerManager.players:
		if MultiplayerManager.players[player].name == %PlayersList.get_item_text(%PlayersList.get_selected_items()[0]):
			multiplayer.multiplayer_peer.disconnect_peer(player)
			return

func _on_start_button_pressed() -> void:
	start_game.rpc()
	
@rpc("authority", "call_local")
func start_game():
	visible = false
	
	if multiplayer.is_server():
		var stage = start_scene.instantiate()
		for child in stage.get_children():
			child.reparent(scene_spawn)
			
	var spawn_point := 0
	for player_id in MultiplayerManager.players:
		var glider : SpaceGlider = load(MultiplayerManager.players[player_id].glider_scene).instantiate()
		glider.global_transform = scene_spawn.get_child(0).spawn_points[spawn_point].global_transform
		glider.set_multiplayer_authority(player_id)
		scene_spawn.add_child(glider)
