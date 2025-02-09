@icon("res://addons/robogodo/icons/glider.svg")
extends RigidBody2D
class_name SpaceGlider

@export_range(0, 1000, 5.0) var fly_speed : float = 300.0
@export_range(0, 360, 0.5, "radians_as_degrees") var rotation_speed : float = PI / 9.0 * 5.0
@export var trails : Array[NodePath]
@export var particles : Array[GPUParticles2D]

@export_group("Input")
@export var forward : StringName = &"forward"
@export var backward : StringName = &"backward"
@export var left : StringName = &"left"
@export var right : StringName = &"right"
@export var brake : StringName = &"brake"
@export var attack : StringName = &"attack"

@export_group("Attack")
@export var projectile : PackedScene
@export var reload : float 

var direction : Vector2 = Vector2.ZERO
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	direction = Vector2.ZERO
	direction.y += int(Input.is_action_pressed(forward))
	direction.y -= int(Input.is_action_pressed(backward))
	direction.x += int(Input.is_action_pressed(right))
	direction.x -= int(Input.is_action_pressed(left))
	
	
