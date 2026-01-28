extends AnimatableBody3D

@export var move_distance: float = 20.0
@export var move_speed: float = 5.0
@export var move_axis: Vector3 = Vector3.RIGHT

var start_position: Vector3
var time: float = 0.0

func _ready():
	start_position = global_position

func _physics_process(delta):
	time += delta * move_speed
	var offset = sin(time) * move_distance
	global_position = start_position + move_axis.normalized() * offset
