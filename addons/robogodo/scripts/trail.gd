@icon("res://addons/robogodo/icons/trail.png")
extends Node2D
class_name Trail

@export var fps : int = 60
@export var color : Gradient
@export var width : float = 4.0
@export var width_curve : Curve
@export var lifetime : float = 1.0
@export var oneshot : bool = false

class TrailNode:

	var position : Vector2
	var lifetime : float
	var active : bool
	var next : TrailNode = null
	
	func _init(position : Vector2, lifetime : float, active : bool = true):
		self.position = position
		self.lifetime = lifetime
		self.active = active
		
var first : TrailNode
var refresh_delay := 0.0
var emitting := false


func _process(delta):
	refresh_delay -= delta
	if refresh_delay <= 0.0:
		refresh_delay += 1.0 / fps
		create_node()

	var node = first
	node.position = global_position
	var hasActiveNode = false
	while node.next:
		if node.next.active: 
			hasActiveNode = true
		node.next.lifetime -= delta
		if node.next.lifetime <= 0.0:
			node.next = null
		else:
			node = node.next

	queue_redraw()
	
	if oneshot and not hasActiveNode and first.next:
		queue_free()
		print("Trail removed")

	global_rotation = 0.0

func _draw():
	var node = first
	while node and node.next:
		if node.active:
			draw_polyline_colors([node.position - global_position, node.next.position - global_position],
			[color.sample(1.0 - node.lifetime / lifetime), color.sample(1.0 - node.next.lifetime / lifetime)],
			width * width_curve.sample(1.0 - node.lifetime / lifetime))
		node = node.next

func create_node():
	var tmp = first
	first = TrailNode.new(global_position, lifetime, emitting)
	first.next = tmp
