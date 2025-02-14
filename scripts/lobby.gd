extends PanelContainer

## Scene which will be set active on all peers when host press 'Start' button.
@export var start_scene : PackedScene
@export var scene_spawn : Node

signal player_added(player : SpaceGlider)

var glider_list_data : Array[Dictionary] = []
var gliders : Array[String] = []

func _ready() -> void:
	#$Setup/VBoxContainer/Label.text = "Session: " + OS.get_cmdline_args()[1]
	
	MultiplayerManager.player_connected.connect(_update_player_list)
	MultiplayerManager.player_disconnected.connect(_update_player_list)
	MultiplayerManager.server_disconnected.connect(_disconnected_from_server)
	MultiplayerManager.player_info.glider_color = 0
	
	var glider_index := 0
	for glider_path in DirAccess.get_files_at("res://gliders"):
		gliders.append(glider_path)
		
		var glider : Node = load("res://gliders/" + glider_path).instantiate()
		var sprite : Sprite2D = glider.get_node("Sprite2D")
		
		glider_list_data.append({})
		glider_list_data[glider_index].region = sprite.region_rect
		glider_list_data[glider_index].display_name = glider.get_meta(&"display_name", "[unknown]")
		glider_list_data[glider_index].display_speed = glider.get_meta(&"display_speed", -1)
		glider_list_data[glider_index].display_maneurity = glider.get_meta(&"display_maneurity", -1)
		glider_list_data[glider_index].display_attack = glider.get_meta(&"display_attack", -1)
		glider_list_data[glider_index].skill_name = glider.get_meta(&"skill_name", "[unknown]")
		glider_list_data[glider_index].skill_desc = glider.get_meta(&"skill_desc", null)
		
		%GlidersList.add_item(glider_list_data[glider_index].display_name)
		
		glider.free()
		
	%GlidersList.selected = 0

func _on_gliders_list_item_selected(index: int) -> void:
	%GliderSprite.region_rect = glider_list_data[index].region

func _on_color_slider_value_changed(value: float) -> void:
	MultiplayerManager.player_info.glider_color = value
	%GliderSprite.material.set_shader_parameter("Shift", value)

func _update_player_list(a, b=null):
	%PlayersList.clear()
	for player in MultiplayerManager.players:
		%PlayersList.add_item(MultiplayerManager.players[player].name)

func _disconnected_from_server():
	$Setup.visible = true
	$PlayersList.visible = false	

func _on_host_button_pressed() -> void:
	%KickButton.disabled = false
	%StartButton.disabled = false
	$Setup.visible = false
	$PlayersList.visible = true
	
	MultiplayerManager.player_info.name = %Nickname.text
	MultiplayerManager.player_info.glider_scene = "res://gliders/" + gliders[%GlidersList.get_selected_id()]
	MultiplayerManager.host_server()

func _on_connect_button_pressed() -> void:
	%KickButton.disabled = true
	%StartButton.disabled = true
	$Setup.visible = false
	$PlayersList.visible = true
	
	MultiplayerManager.player_info.name = %Nickname.text
	MultiplayerManager.player_info.glider_scene = "res://gliders/" + gliders[%GlidersList.get_selected_id()]
	MultiplayerManager.join_server(%IPAddres.text)


func _on_kick_button_pressed() -> void:
	for player in MultiplayerManager.players:
		if MultiplayerManager.players[player].name == %PlayersList.get_item_text(%PlayersList.get_selected_items()[0]):
			multiplayer.multiplayer_peer.disconnect_peer(player)
			return

func _on_start_button_pressed() -> void:
	for child in start_scene.instantiate().get_children():
		child.reparent(scene_spawn)
		
	start_game.rpc()
	
	var spawn_point := 0
	for player_id in MultiplayerManager.players:
		spawn_player.rpc(get_tree().get_nodes_in_group("spawn_points")[spawn_point].transform, player_id)
		spawn_point += 1
	
@rpc("call_local", "reliable")
func start_game():
	visible = false
	print(MultiplayerManager.player_info)
	print(MultiplayerManager.players)

@rpc("call_local", "reliable")
func spawn_player(transform : Transform2D, id : int):
	var glider : SpaceGlider = load(MultiplayerManager.players[id].glider_scene).instantiate()
	glider.tree_entered.connect(func(): 
		glider.transform = transform
		glider.set_multiplayer_authority(id)	
		player_added.emit(glider)
		glider.get_node("Sprite2D").material.set_shader_parameter.call_deferred("Shift", MultiplayerManager.players[id].glider_color)
	)
	get_tree().current_scene.add_child(glider)
	
