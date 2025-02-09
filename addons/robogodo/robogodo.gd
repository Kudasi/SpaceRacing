@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("Trail2D", "Node2D", preload("res://addons/robogodo/scripts/trail.gd"), preload("res://addons/robogodo/icons/trail.png"))
	add_custom_type("SmartParallax", "Node2D", preload("res://addons/robogodo/scripts/smart_parallax.gd"), null)
	add_custom_type("SpaceGlider", "RigidBody2D", preload("res://addons/robogodo/scripts/space_glider.gd"), preload("res://addons/robogodo/icons/glider.svg"))
	pass


func _exit_tree() -> void:
	remove_custom_type("Trail2D")
	remove_custom_type("SmartParallax")
	remove_custom_type("SpaceGlider")
	pass
