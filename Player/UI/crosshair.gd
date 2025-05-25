extends Control
class_name Crosshair

@export var radius: float = 2.0
@export var thickness: float = 10.0
@export var arc_angle: float = PI / 4.0 # 45 degrees
@export var arc_offset_angle: float = 0.0 # Rotate the arcs around the center

@export var color : Color = Color.BLACK
@export var grapple_color : Color = Color.YELLOW

@onready var middle_crosshair: ColorRect = $MiddleCrosshair
	
func draw_crosshair(color: Color):
	middle_crosshair.color = color
