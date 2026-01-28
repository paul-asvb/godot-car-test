extends RigidBody3D

# Suspension parameters
const SPRING_STRENGTH = 150.0
const SPRING_DAMPING = 10.0
const REST_LENGTH = 0.5
const WHEEL_RADIUS = 0.2

# Drive parameters
const ENGINE_FORCE = 40.0
const BRAKE_FORCE = 20.0
const MAX_STEER_ANGLE = 0.4
const STEER_SPEED = 3.0

# Tire grip
const TIRE_GRIP = 0.8
const TIRE_MASS = 1.0

# Anti-roll stability
const ANTI_ROLL_STRENGTH = 50.0
const ANGULAR_DAMPING_MULTIPLIER = 3.0

var current_steer = 0.0

@onready var wheels = [
	$WheelFL,
	$WheelFR,
	$WheelRL,
	$WheelRR
]

func _physics_process(delta):
	var steer_input = 0.0
	if Input.is_action_pressed("ui_left"):
		steer_input += 1.0
	if Input.is_action_pressed("ui_right"):
		steer_input -= 1.0
	
	current_steer = move_toward(current_steer, steer_input * MAX_STEER_ANGLE, STEER_SPEED * delta)
	
	var throttle = 0.0
	if Input.is_action_pressed("ui_up"):
		throttle += 1.0
	if Input.is_action_pressed("ui_down"):
		throttle -= 1.0
	
	for i in range(wheels.size()):
		var wheel: RayCast3D = wheels[i]
		if not wheel.is_colliding():
			continue
		
		var contact_point = wheel.get_collision_point()
		var contact_normal = wheel.get_collision_normal()
		var wheel_pos = wheel.global_position
		
		# Suspension force (spring + damper)
		var ray_length = REST_LENGTH + WHEEL_RADIUS
		var distance = wheel_pos.distance_to(contact_point)
		var compression = ray_length - distance
		
		if compression > 0:
			var wheel_velocity = get_point_velocity(wheel_pos)
			var vertical_velocity = contact_normal.dot(wheel_velocity)
			
			var spring_force = compression * SPRING_STRENGTH
			var damper_force = -vertical_velocity * SPRING_DAMPING
			var suspension_force = contact_normal * (spring_force + damper_force)
			
			apply_force(suspension_force, wheel_pos - global_position)
			
			# Calculate tire forces
			var forward_dir = -global_transform.basis.z
			var right_dir = global_transform.basis.x
			
			# Apply steering to front wheels (indices 0 and 1)
			if i < 2:
				forward_dir = forward_dir.rotated(Vector3.UP, current_steer)
				right_dir = right_dir.rotated(Vector3.UP, current_steer)
			
			# Lateral grip (prevent sliding)
			var lateral_velocity = right_dir.dot(wheel_velocity)
			var lateral_force = -right_dir * lateral_velocity * TIRE_GRIP * TIRE_MASS * 60.0
			apply_force(lateral_force, wheel_pos - global_position)
			
			# Drive force (rear wheel drive - indices 2 and 3)
			if i >= 2 and throttle != 0:
				var drive_force = forward_dir * throttle * ENGINE_FORCE
				apply_force(drive_force, wheel_pos - global_position)
	
	# Anti-roll stabilization
	apply_anti_roll()
	
	# Dampen roll and pitch angular velocity
	var local_angular = global_transform.basis.inverse() * angular_velocity
	local_angular.x *= 1.0 - (ANGULAR_DAMPING_MULTIPLIER * delta)
	local_angular.z *= 1.0 - (ANGULAR_DAMPING_MULTIPLIER * delta)
	angular_velocity = global_transform.basis * local_angular

func apply_anti_roll():
	var up = global_transform.basis.y
	var target_up = Vector3.UP
	var correction = up.cross(target_up)
	apply_torque(correction * ANTI_ROLL_STRENGTH)

func get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)
