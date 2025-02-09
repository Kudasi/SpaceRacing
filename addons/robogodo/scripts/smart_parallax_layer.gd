extends Resource
class_name SmartParallaxLayer

@export var texture : Texture2D

## The coefficient of camera following. Zero means that layer is completely static and not follows camera. One means that layer is immovable on screen, and fully follows camera coordinates.
@export_range(0.0, 1.0, 0.001) var lambda : float = 0.2
