@icon("res://addons/robogodo/icons/glider.svg")
extends RigidBody2D
class_name SpaceGlider

@export_range(100, 1000, 5.0) var fly_speed : float = 300.0
@export_range(180, 360, 0.5, "radians_as_degrees") var rotation_speed : float = PI / 9.0 * 5.0
@export_range(0, 1.0, 0.01) var stabilization : float = 0.1
@export_range(0.05, 1.0) var braking_power : float = 0.1
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
var braking : bool = 0

func _ready() -> void:
	angular_damp = rotation_speed
	
func _process(delta: float) -> void:
	
	if not is_multiplayer_authority(): return
	
	direction = Vector2.ZERO
	direction.y += int(Input.is_action_pressed(forward))
	direction.y -= int(Input.is_action_pressed(backward))
	direction.x += int(Input.is_action_pressed(right))
	direction.x -= int(Input.is_action_pressed(left))
	
	braking = Input.is_action_pressed("brake")
	
func _physics_process(delta: float) -> void:
	for trail in trails:
		get_node(trail).emitting = direction.y > 0
		
	if not is_multiplayer_authority(): return
	
	if direction.x != 0:
		apply_torque_impulse(direction.x * rotation_speed * 2500.0 * delta * (1 - int(braking)))
		linear_velocity = linear_velocity
	
	linear_damp = absf(direction.y) * 10.0 * stabilization + 10.0 * int(braking) * braking_power
	apply_central_impulse(Vector2.from_angle(rotation) * direction.y * 2.0 ** direction.y * fly_speed * delta * 10.0 * stabilization)
	
