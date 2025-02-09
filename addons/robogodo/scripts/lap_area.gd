@icon("res://addons/robogodo/icons/lap_area.svg")
extends Area2D
class_name LapArea

@export var start : bool
@export var next : LapArea

func _ready() -> void:
	monitorable = false
	
	if not start: 
		visible = false
		monitoring = false
		
	#body_entered.connect()
	
func _on_body_entered(body : PhysicsBody2D):
	if body.is_in_group("players") and body.get_meta(&"id") == multiplayer.get_unique_id():
		if next:
			visible = false
			monitoring = false
			
			next.visible = true
			next.monitoring = true
		#else:
			
			
