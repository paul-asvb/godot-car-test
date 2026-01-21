extends CharacterBody3D

const SPEED = 15.0
const ROT_SPEED = 3.0
const ACCEL = 10.0
const FRICTION = 5.0

func _physics_process(delta):
	# Input: Left/Right to turn, Up/Down to move forward/backward
	# Note: In Godot, negative Z is forward.
	
	var rot_dir = 0
	if Input.is_action_pressed("ui_left"):
		rot_dir += 1
	if Input.is_action_pressed("ui_right"):
		rot_dir -= 1
		
	var move_dir = 0
	# Pressing UP (forward) should move in -Z
	if Input.is_action_pressed("ui_up"):
		move_dir += 1
	if Input.is_action_pressed("ui_down"):
		move_dir -= 1

	# Rotate
	if move_dir != 0:
		# Only rotate when moving for realistic car feels, or always for arcade?
		# Let's rotate always for simplicity
		pass
	rotate_y(rot_dir * ROT_SPEED * delta)
	
	# Move
	if move_dir != 0:
		# Transform.basis.z is backward, so -basis.z is forward
		var direction = -global_transform.basis.z * move_dir
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCEL * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0, FRICTION * delta)

	# Simple gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	move_and_slide()
