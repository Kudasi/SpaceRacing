extends Camera2D

@export var target : RigidBody2D

func _process(delta: float) -> void:
	position = position.lerp(target.position + get_local_mouse_position() * 0.5 + target.linear_velocity * 0.5, delta * 10.0)
	zoom = zoom.lerp(Vector2.ONE / (1.0 + (get_local_mouse_position()).length() * 0.0006), delta)
