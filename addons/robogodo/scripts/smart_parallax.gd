extends Node2D
class_name SmartParallax

@export var follow_zoom : bool
@export var layers : Array[SmartParallaxLayer]

func _init() -> void:
	z_index = -100

func _process(delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	draw_set_transform_matrix(transform.inverse())
	var camera : Camera2D = get_viewport().get_camera_2d()
	for layer in layers:
		var size : Vector2 = Vector2.ONE + Vector2(get_viewport_rect().size) / layer.texture.get_size() / camera.zoom
		var origin : Vector2 = (camera.global_position / layer.texture.get_size()).floor()
		var offset : Vector2 = (camera.global_position * layer.lambda).posmodv(layer.texture.get_size())
		for x in range(-int(size.x / 2 + 1), int(size.x / 2 + 1)):
			for y in range(-int(size.y / 2 + 1), int(size.y / 2 + 1)):
				draw_texture(layer.texture, (Vector2(x, y) + origin) * layer.texture.get_size() + offset)
		
	
