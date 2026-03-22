extends CharacterBody3D

"""
Arcade-style kart physics using CharacterBody3D.

Phase 1: Core Arcade Physics
- Velocity-based movement (not force-based RigidBody3D)
- Mario Kart 8 style: fast acceleration, responsive steering, no grip limits
- Ground-hugging via raycast detection and surface alignment

Phase 2: Drift & Boost System
- Three-state machine (NORMAL/DRIFTING/BOOSTING)
- MK8-style drift: brake + turn to enter, lateral slide, reduced steering
- Three boost tiers (blue/orange/pink) at 0.5s/1.5s/3.0s
- Boost rewards: +10%/+20%/+35% speed for 1.5s
- Can chain: drift → boost → normal → drift

Constants tuned for:
- Instant drift entry, wide arc slide (DRIFT-01, DRIFT-02)
- Tier progression at 0.5s/1.5s/3.0s (DRIFT-04/05/06)
- Boost multipliers 1.10x/1.20x/1.35x (DRIFT-08)
- Smooth decay over 1.5 seconds
- See Phase 1 docstring for movement constants

Dependencies:
- Requires WheelFL/FR/RL/RR RayCast3D children in scene
- Requires wheel mesh children for visual updates
- Phase 3 (Visual Feedback) will add spark colors and boost flames

Tuning guide:
- Movement: MAX_SPEED, ACCELERATION, TURN_SPEED, etc.
- Drift entry: DRIFT_MIN_SPEED, DRIFT_SPEED_RETENTION
- Drift physics: DRIFT_SLIDE_ANGLE, DRIFT_TURN_RATE_MULT
- Boost tiers: TIER1/2/3_TIME, TIER1/2/3_BOOST
- Boost decay: BOOST_DURATION
- All key constants are @export for runtime tuning in Inspector
"""

@export_group("Movement")
@export var MAX_SPEED = 35.0              ## Top speed (units/second)
@export var ACCELERATION = 20.0           ## How fast speed increases
@export var DECELERATION = 8.0            ## Coasting slowdown rate
@export var BRAKE_FORCE = 25.0            ## Active braking strength
@export var REVERSE_SPEED = 15.0          ## Backward max speed

@export_group("Steering")
@export var TURN_SPEED = 2.5              ## Steering interpolation speed
@export var MAX_TURN_RATE = 2.0           ## Maximum turn rate (radians/sec)

@export_group("Ground Behavior")
@export var GROUND_ALIGN_SPEED = 8.0      ## Surface alignment smoothness
@export var GRAVITY = 25.0                ## Jump/fall acceleration

@export_group("Drift Entry")
@export var DRIFT_MIN_SPEED = 15.0        ## Minimum speed to enter drift
@export var DRIFT_SPEED_RETENTION = 0.95  ## Speed multiplier during drift (95%)

@export_group("Drift Physics")
@export var DRIFT_SLIDE_ANGLE = 25.0       ## Lateral slide angle (degrees)
@export var DRIFT_TURN_RATE_MULT = 0.3     ## Steering strength during drift (30%)

@export_group("Boost Tiers")
@export var TIER1_TIME = 0.5               ## Blue spark threshold (seconds)
@export var TIER2_TIME = 1.5               ## Orange spark threshold (seconds)
@export var TIER3_TIME = 3.0               ## Pink spark threshold (seconds)
@export var TIER1_BOOST = 1.10             ## Tier 1 boost multiplier (110% speed)
@export var TIER2_BOOST = 1.20             ## Tier 2 boost multiplier (120% speed)
@export var TIER3_BOOST = 1.35             ## Tier 3 boost multiplier (135% speed)

@export_group("Boost")
@export var BOOST_DURATION = 1.5           ## Boost duration (seconds)

# Fixed constants (not tunable - tied to scene/mesh dimensions)
const HOVER_HEIGHT = 0.1            # Slight lift above ground (prevents friction)
const RAYCAST_LENGTH = 1.0          # Ground detection range
const WHEEL_RADIUS = 0.35           # Matches car.gd line 7
const WHEEL_SMOOTH_SPEED = 20.0     # Matches car.gd line 8
const REST_LENGTH = 0.6              # Matches car.gd line 6

# State machine
enum State { NORMAL, DRIFTING, BOOSTING }
var current_state: State = State.NORMAL

# State variables
var current_speed: float = 0.0      # Forward speed (signed: positive = forward, negative = reverse)
var current_turn: float = 0.0       # Steering amount (-1 to 1, interpolated)
var is_grounded: bool = false       # Set by ground detection
var ground_normal: Vector3 = Vector3.UP  # Surface normal for alignment
var ground_distance: float = 0.0         # Average distance to ground

# Drift state
var drift_timer: float = 0.0
var current_tier: int = 0  # 0-3 (0 = no tier, 1-3 = blue/orange/pink)
var drift_direction: float = 0.0  # -1 (left) or 1 (right), set on entry
var drift_entry_speed: float = 0.0

# Boost state
var boost_timer: float = 0.0
var boost_multiplier: float = 1.0
var initial_boost_mult: float = 1.0

# Wheel raycasts (reuse from car.gd lines 22-27)
@onready var wheels = [
	$WheelFL,
	$WheelFR,
	$WheelRL,
	$WheelRR
]

# Wheel meshes for visual updates (car.gd lines 29-34)
@onready var wheel_meshes = [
	$WheelFL/WheelMeshFL,
	$WheelFR/WheelMeshFR,
	$WheelRL/WheelMeshRL,
	$WheelRR/WheelMeshRR
]

# Drift spark particles (Phase 3) - created programmatically if not in scene
var drift_sparks = []
var boost_flames = null
var speed_lines = null

# Camera (Phase 3)
@onready var camera = $Camera3D
var camera_base_offset = Vector3(0, 3, 5)  # Default camera position from scene
var camera_drift_offset = Vector3.ZERO


func _ready():
	"""Initialize particle effects."""
	_create_drift_sparks()
	_create_boost_flames()
	_create_speed_lines()


func _create_drift_sparks() -> void:
	"""Create drift spark particles programmatically at each wheel."""
	for wheel in wheels:
		var spark = GPUParticles3D.new()
		spark.name = "DriftSpark"
		spark.emitting = false
		spark.amount = 30
		spark.lifetime = 0.4
		spark.local_coords = false
		
		# Create process material
		var mat = ParticleProcessMaterial.new()
		mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
		mat.direction = Vector3(0, 0.3, -1)
		mat.spread = 25.0
		mat.initial_velocity_min = 4.0
		mat.initial_velocity_max = 7.0
		mat.gravity = Vector3(0, -9.8, 0)
		mat.color = Color(0.3, 0.5, 1.0)  # Blue (tier 1)
		mat.scale_min = 0.1
		mat.scale_max = 0.2
		spark.process_material = mat
		
		# Create quad mesh for particles
		var quad = QuadMesh.new()
		quad.size = Vector2(0.15, 0.15)
		spark.draw_pass_1 = quad
		
		# Add as child of wheel
		wheel.add_child(spark)
		drift_sparks.append(spark)


func _create_boost_flames() -> void:
	"""Create boost flame particles at kart rear."""
	boost_flames = GPUParticles3D.new()
	boost_flames.name = "BoostFlames"
	boost_flames.emitting = false
	boost_flames.amount = 35
	boost_flames.lifetime = 0.6
	boost_flames.local_coords = false
	
	# Create process material (orange to red gradient)
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 0.3
	mat.direction = Vector3(0, 0.5, 1)  # Behind and slightly up
	mat.spread = 20.0
	mat.initial_velocity_min = 3.0
	mat.initial_velocity_max = 6.0
	mat.gravity = Vector3(0, 1.0, 0)  # Rise slightly
	
	# Color gradient: orange → red → dark
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.6, 0.1))  # Bright orange
	gradient.add_point(0.5, Color(1.0, 0.2, 0.0))  # Red
	gradient.add_point(1.0, Color(0.2, 0.0, 0.0))  # Dark red/black
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex
	
	mat.scale_min = 0.3
	mat.scale_max = 0.5
	boost_flames.process_material = mat
	
	# Create quad mesh
	var quad = QuadMesh.new()
	quad.size = Vector2(0.4, 0.4)
	boost_flames.draw_pass_1 = quad
	
	# Position at kart rear
	boost_flames.position = Vector3(0, 0, 1.5)  # Behind kart center
	add_child(boost_flames)


func _create_speed_lines() -> void:
	"""Create speed lines effect near camera."""
	speed_lines = GPUParticles3D.new()
	speed_lines.name = "SpeedLines"
	speed_lines.emitting = false
	speed_lines.amount = 60
	speed_lines.lifetime = 0.3
	speed_lines.local_coords = false
	
	# Create process material (streaks moving backward)
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(5, 3, 2)  # Around camera view
	mat.direction = Vector3(0, 0, 1)  # Backward
	mat.spread = 0.0
	mat.initial_velocity_min = 50.0
	mat.initial_velocity_max = 60.0
	mat.gravity = Vector3.ZERO
	mat.color = Color(1.0, 1.0, 1.0, 0.5)  # Semi-transparent white
	mat.scale_min = 0.05
	mat.scale_max = 0.1
	speed_lines.process_material = mat
	
	# Create line-shaped mesh
	var quad = QuadMesh.new()
	quad.size = Vector2(0.05, 0.5)  # Thin and elongated
	speed_lines.draw_pass_1 = quad
	
	# Position near camera
	speed_lines.position = Vector3(0, 2, 3)  # In front of camera
	add_child(speed_lines)


func _input(event):
	# ESC returns to menu (same as car.gd lines 37-38)
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _handle_acceleration(delta: float, throttle_input: float, brake_input: bool) -> void:
	"""
	Handle forward/reverse acceleration and braking.
	State-aware: skipped during drift (speed locked).
	
	Args:
		throttle_input: -1 to 1 (negative = reverse, positive = forward, 0 = coast)
		brake_input: true if brake button held
	"""
	# Skip acceleration logic during drift or boost
	if current_state == State.DRIFTING or current_state == State.BOOSTING:
		return
	
	if brake_input and current_speed > 0:
		# Braking while moving forward
		current_speed = move_toward(current_speed, 0.0, BRAKE_FORCE * delta)
	elif brake_input and abs(current_speed) < 0.1:
		# Brake held while stopped -> engage reverse
		current_speed = move_toward(current_speed, -REVERSE_SPEED, ACCELERATION * delta)
	elif throttle_input > 0:
		# Forward acceleration
		current_speed = move_toward(current_speed, MAX_SPEED, ACCELERATION * delta)
	elif throttle_input < 0:
		# Reverse input (alternative to brake-to-reverse)
		current_speed = move_toward(current_speed, -REVERSE_SPEED, ACCELERATION * delta)
	else:
		# No input - coast to stop
		current_speed = move_toward(current_speed, 0.0, DECELERATION * delta)


func _check_drift_conditions() -> bool:
	"""
	Check if conditions are met to enter drift state.
	Returns true if all entry conditions satisfied.
	"""
	var brake_held = Input.is_action_pressed("ui_down")
	var turn_left = Input.is_action_pressed("ui_left")
	var turn_right = Input.is_action_pressed("ui_right")
	var has_turn_input = turn_left or turn_right
	
	return (
		brake_held and
		has_turn_input and
		is_grounded and
		current_speed >= DRIFT_MIN_SPEED and
		current_state == State.NORMAL  # Can only enter from normal state
	)


func _get_drift_direction() -> float:
	"""
	Determine drift direction from input.
	Returns -1.0 for left, 1.0 for right, 0.0 if no turn input.
	"""
	if Input.is_action_pressed("ui_left"):
		return -1.0  # Left drift
	elif Input.is_action_pressed("ui_right"):
		return 1.0  # Right drift
	return 0.0


func _enter_drift() -> void:
	"""
	Enter drift state. Initializes drift variables and transitions state.
	Called when drift conditions met.
	"""
	current_state = State.DRIFTING
	drift_timer = 0.0
	current_tier = 0
	drift_direction = _get_drift_direction()
	drift_entry_speed = current_speed * DRIFT_SPEED_RETENTION  # 95% of current speed
	
	# Lock speed to entry speed during drift
	current_speed = drift_entry_speed


func _update_drift_sparks() -> void:
	"""
	Control drift spark emission and color based on state and tier.
	Called every frame from _physics_process.
	"""
	var should_emit = (current_state == State.DRIFTING)
	var spark_color = _get_tier_color(current_tier)
	
	for spark in drift_sparks:
		spark.emitting = should_emit
		
		# Update color if material exists
		if spark.process_material:
			var mat: ParticleProcessMaterial = spark.process_material
			mat.color = spark_color


func _get_tier_color(tier: int) -> Color:
	"""
	Get spark color for given tier.
	Returns white if no tier (tier 0).
	"""
	match tier:
		1: return Color(0.3, 0.5, 1.0)   # Blue (tier 1)
		2: return Color(1.0, 0.5, 0.1)   # Orange (tier 2)
		3: return Color(1.0, 0.2, 0.8)   # Pink (tier 3)
		_: return Color.WHITE            # No tier


func _update_boost_flames() -> void:
	"""Control boost flame emission based on boost state."""
	if boost_flames:
		boost_flames.emitting = (current_state == State.BOOSTING)


func _update_speed_lines() -> void:
	"""Control speed lines based on current speed."""
	if speed_lines:
		# Fade in above 25 u/s, full intensity at MAX_SPEED
		var speed_threshold = 25.0
		speed_lines.emitting = (current_speed > speed_threshold)
		
		# Adjust intensity based on speed
		if speed_lines.emitting and speed_lines.process_material:
			var intensity = clamp((current_speed - speed_threshold) / (MAX_SPEED - speed_threshold), 0.0, 1.0)
			var mat: ParticleProcessMaterial = speed_lines.process_material
			mat.color.a = intensity * 0.5  # Max 50% opacity


func _update_camera(delta: float) -> void:
	"""
	Update camera position for smooth following and drift offset.
	VFX-05: Smooth following with lerp
	VFX-06: Drift offset for better turn visibility
	"""
	# Calculate drift offset (shift opposite drift direction)
	var target_drift_offset = Vector3.ZERO
	if current_state == State.DRIFTING:
		target_drift_offset.x = -drift_direction * 1.5  # 1.5 units lateral
	
	# Smooth transition to target offset
	camera_drift_offset = camera_drift_offset.lerp(target_drift_offset, 5.0 * delta)
	
	# Apply combined offset (base + drift)
	var target_pos = camera_base_offset + camera_drift_offset
	camera.position = camera.position.lerp(target_pos, 0.15)  # Smooth following


func _update_drifting(delta: float) -> void:
	"""
	Update drift state. Handles tier progression and drift physics.
	Called every frame while in DRIFTING state.
	"""
	# Accumulate drift timer
	drift_timer += delta
	
	# Check tier thresholds (highest first, no regression)
	if drift_timer >= TIER3_TIME and current_tier < 3:
		current_tier = 3
		# TODO Phase 3: trigger pink spark effect
	elif drift_timer >= TIER2_TIME and current_tier < 2:
		current_tier = 2
		# TODO Phase 3: trigger orange spark effect
	elif drift_timer >= TIER1_TIME and current_tier < 1:
		current_tier = 1
		# TODO Phase 3: trigger blue spark effect
	
	# Check for drift exit (brake release)
	if not Input.is_action_pressed("ui_down"):
		_exit_drift()
		return
	
	# Cancel drift if airborne
	if not is_grounded:
		_cancel_drift()
		return
	
	# Cancel drift if too slow
	if current_speed < 10.0:
		_cancel_drift()
		return


func _exit_drift() -> void:
	"""
	Exit drift state and apply boost based on tier reached.
	Called when brake released during drift.
	"""
	# Determine boost multiplier from tier
	var boost_mult = _get_boost_for_tier(current_tier)
	
	# Transition to boosting state if tier reached
	if current_tier > 0:
		current_state = State.BOOSTING
		boost_timer = 0.0
		initial_boost_mult = boost_mult
		boost_multiplier = boost_mult
	else:
		# No tier reached, return to normal
		current_state = State.NORMAL
	
	# Reset drift state
	drift_timer = 0.0
	current_tier = 0
	drift_direction = 0.0


func _cancel_drift() -> void:
	"""
	Cancel drift without awarding boost.
	Called when drift conditions violated (airborne, too slow).
	"""
	current_state = State.NORMAL
	drift_timer = 0.0
	current_tier = 0
	drift_direction = 0.0


func _get_boost_for_tier(tier: int) -> float:
	"""
	Get boost multiplier for given tier.
	Returns 1.0 (no boost) if tier is 0.
	"""
	match tier:
		1: return TIER1_BOOST  # 1.10 (10%)
		2: return TIER2_BOOST  # 1.20 (20%)
		3: return TIER3_BOOST  # 1.35 (35%)
		_: return 1.0  # No tier = no boost


func _update_boosting(delta: float) -> void:
	"""
	Update boost state. Handles boost decay over time.
	Called every frame while in BOOSTING state.
	"""
	boost_timer += delta
	
	# Linear decay from initial_boost_mult to 1.0 over BOOST_DURATION
	var progress = clamp(boost_timer / BOOST_DURATION, 0.0, 1.0)
	boost_multiplier = lerp(initial_boost_mult, 1.0, progress)
	
	# Exit boost when duration expires
	if boost_timer >= BOOST_DURATION:
		_exit_boost()


func _exit_boost() -> void:
	"""
	Exit boost state and return to normal.
	Called when boost duration expires.
	"""
	current_state = State.NORMAL
	boost_timer = 0.0
	boost_multiplier = 1.0
	initial_boost_mult = 1.0


func _handle_steering(delta: float, steer_input: float) -> void:
	"""
	Handle steering with smooth interpolation.
	State-aware: reduced turn rate during drift.
	
	Args:
		steer_input: -1 to 1 (negative = right, positive = left)
	"""
	# Adjust turn speed based on state
	var effective_turn_speed = TURN_SPEED
	var effective_turn_rate = MAX_TURN_RATE
	
	if current_state == State.DRIFTING:
		# Reduced steering during drift (30% of normal per CONTEXT.md)
		effective_turn_rate *= DRIFT_TURN_RATE_MULT
	
	# Interpolate current_turn toward input
	current_turn = move_toward(current_turn, steer_input, effective_turn_speed * delta)
	
	# Apply rotation based on current_turn and speed
	var turn_amount = current_turn * effective_turn_rate * delta
	rotate_y(turn_amount)


func _update_ground_state() -> void:
	"""
	Detect ground using 4 wheel raycasts and calculate average normal.
	Updates: is_grounded, ground_normal, ground_distance
	"""
	var hits = 0
	var normal_sum = Vector3.ZERO
	var distance_sum = 0.0
	
	for i in range(wheels.size()):
		var wheel: RayCast3D = wheels[i]
		
		if wheel.is_colliding():
			hits += 1
			normal_sum += wheel.get_collision_normal()
			
			# Calculate distance from wheel to hit point
			var wheel_pos = wheel.global_position
			var hit_pos = wheel.get_collision_point()
			distance_sum += wheel_pos.distance_to(hit_pos)
	
	if hits > 0:
		# At least one wheel touching ground
		is_grounded = true
		ground_normal = (normal_sum / hits).normalized()
		ground_distance = distance_sum / hits
	else:
		# Airborne
		is_grounded = false
		ground_normal = Vector3.UP  # Default to upright in air
		ground_distance = 0.0


func _align_to_ground(delta: float) -> void:
	"""
	Smoothly align kart's orientation to ground_normal.
	Uses basis interpolation for smooth surface following.
	"""
	if not is_grounded:
		return  # Don't align in air
	
	# Build target basis from ground_normal (per RESEARCH.md)
	var up = ground_normal.normalized()
	var forward = -global_transform.basis.z
	
	# Project forward vector onto ground plane
	forward = forward - up * forward.dot(up)
	forward = forward.normalized()
	
	# Calculate right vector
	var right = forward.cross(up)
	
	# Build target basis
	var target_basis = Basis(right, up, -forward)
	
	# Smoothly interpolate to target (per RESEARCH.md: slerp for rotation interpolation)
	transform.basis = transform.basis.slerp(target_basis, GROUND_ALIGN_SPEED * delta)
	
	# Adjust height to maintain hover above ground
	var target_height = ground_distance - WHEEL_RADIUS + HOVER_HEIGHT
	position.y = lerp(position.y, position.y + target_height, GROUND_ALIGN_SPEED * delta)


func _update_wheel_meshes(delta: float) -> void:
	"""
	Update wheel mesh positions based on raycast hits.
	Provides visual feedback of suspension compression.
	"""
	for i in range(wheels.size()):
		var wheel: RayCast3D = wheels[i]
		var wheel_mesh: MeshInstance3D = wheel_meshes[i]
		
		if not wheel.is_colliding():
			# Wheel fully extended when not touching ground
			wheel_mesh.position.y = -REST_LENGTH
			continue
		
		# Calculate wheel position from raycast hit
		var wheel_pos = wheel.global_position
		var contact_point = wheel.get_collision_point()
		var distance = wheel_pos.distance_to(contact_point)
		
		# Update wheel mesh position (reuses car.gd lines 73-76 pattern)
		var wheel_y = -(distance - WHEEL_RADIUS)
		var target_y = clamp(wheel_y, -REST_LENGTH, 0)
		wheel_mesh.position.y = lerp(wheel_mesh.position.y, target_y, WHEEL_SMOOTH_SPEED * delta)


func reset_position() -> void:
	"""Reset kart to starting position when out of bounds or flipped."""
	global_position = Vector3(0, 2, 0)  # Starting position (2 units above origin)
	global_rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	current_speed = 0.0
	current_turn = 0.0


func _physics_process(delta: float) -> void:
	# Read input (reuse action names from car.gd lines 42-53)
	var steer_input = 0.0
	if Input.is_action_pressed("ui_left"):
		steer_input += 1.0
	if Input.is_action_pressed("ui_right"):
		steer_input -= 1.0
	
	var throttle = 0.0
	if Input.is_action_pressed("ui_up"):
		throttle += 1.0
	if Input.is_action_pressed("ui_down"):
		throttle -= 1.0
	
	var brake = Input.is_action_pressed("ui_down")
	
	# Check for drift entry (Phase 2)
	if _check_drift_conditions():
		_enter_drift()
	
	# State-specific updates
	if current_state == State.DRIFTING:
		_update_drifting(delta)
	elif current_state == State.BOOSTING:
		_update_boosting(delta)
	
	# Handle steering
	_handle_steering(delta, steer_input)
	
	# Handle acceleration
	_handle_acceleration(delta, throttle, brake)
	
	# Calculate velocity from current_speed and forward direction
	var forward = -global_transform.basis.z  # Godot 3D forward is -Z (per AGENTS.md)
	
	# Apply lateral slide during drift
	if current_state == State.DRIFTING:
		# Drift slide: forward + lateral component
		var lateral = global_transform.basis.x  # Right direction
		var slide_angle_rad = deg_to_rad(DRIFT_SLIDE_ANGLE)
		var slide_amount = sin(slide_angle_rad) * current_speed * drift_direction
		velocity = (forward * current_speed) + (lateral * slide_amount)
	else:
		# Normal/Boosting: straight forward
		var effective_speed = current_speed
		if current_state == State.BOOSTING:
			effective_speed *= boost_multiplier
		velocity = forward * effective_speed
	
	# Update ground detection using raycasts
	_update_ground_state()
	
	# Apply gravity if airborne
	if not is_grounded:
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0  # Stick to ground when grounded
		_align_to_ground(delta)  # Align to surface normal
	
	# Move the kart (CharacterBody3D built-in method)
	move_and_slide()
	
	# Update wheel visuals (called after ground detection)
	_update_wheel_meshes(delta)
	
	# Update visual effects (Phase 3)
	_update_drift_sparks()
	_update_boost_flames()
	_update_speed_lines()
	_update_camera(delta)
	
	# Reset if out of bounds or flipped (reuse car.gd logic)
	var boundary_x = 28.0  # Environment size (60x60 ground, ±30 boundary, leave margin)
	var boundary_z = 38.0  # Environment size (80 depth, ±40 boundary, leave margin)
	var up_dot = global_transform.basis.y.dot(Vector3.UP)
	
	if abs(global_position.x) > boundary_x or abs(global_position.z) > boundary_z or global_position.y < -5 or up_dot < 0.3:
		reset_position()
