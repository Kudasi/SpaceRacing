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

func _ready() -> void:
	angular_damp = rotation_speed / 10.0
	
func _process(delta: float) -> void:
	
	if not is_multiplayer_authority(): return
	
	direction = Vector2.ZERO
	direction.y += int(Input.is_action_pressed(forward))
	direction.y -= int(Input.is_action_pressed(backward))
	direction.x += int(Input.is_action_pressed(right))
	direction.x -= int(Input.is_action_pressed(left))
	
	print(direction)
	
func _physics_process(delta: float) -> void:
	for trail in trails:
		get_node(trail).emitting = direction.y > 0
		
	if not is_multiplayer_authority(): return
	
	apply_central_impulse(Vector2.from_angle(rotation) * direction.y * 2.0 ** direction.y * fly_speed * delta)
	apply_torque_impulse(direction.x * rotation_speed * 1000.0 * delta)
