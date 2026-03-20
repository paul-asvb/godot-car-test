# Conventions Analysis

**Analyzed:** 2026-03-20
**Codebase:** Godot 4.5 3D Game

## Code Style

**Language:** GDScript (Godot 4.x)

**Indentation:** Tabs (Godot default)
- Consistent throughout codebase
- GDScript enforces significant indentation (Python-like)

**Naming Conventions:**

```gdscript
# Constants: SCREAMING_SNAKE_CASE
const SPRING_STRENGTH = 200.0
const ENGINE_FORCE = 40.0
const MAX_STEER_ANGLE = 0.4

# Variables: snake_case
var current_steer = 0.0
var start_position: Vector3
var time: float = 0.0

# Functions: snake_case
func reset_position():
func get_point_velocity(point: Vector3) -> Vector3:

# Classes/Nodes: PascalCase (in scene tree)
# Car, Ground, DirectionalLight3D, WheelFL

# Signals: snake_case (Godot convention)
# pressed, ready, body_entered

# Files: snake_case.gd / snake_case.tscn
# car.gd, moving_obstacle.gd, main.tscn
```

**Line Length:** No strict limit
- Most lines under 100 characters
- Some scene file lines longer (transform matrices)

**Comments:**
- Sparse but present
- Purpose comments for sections: `# Suspension parameters`, `# Drive parameters`
- Important notes: `# Important: In Godot 3D, negative Z is forward`
- No function docstrings (GDScript doesn't enforce)

## Type System

**Dynamic Typing (mostly):**
```gdscript
var current_steer = 0.0              # Type inferred
var time: float = 0.0                # Explicit type annotation (rare)
var start_position: Vector3          # Explicit type (more common)
```

**Function Signatures:**
```gdscript
func _physics_process(delta):        # No type annotations
func get_point_velocity(point: Vector3) -> Vector3:  # Explicit types
```

**Pattern:** Type annotations used inconsistently
- More common for exported variables: `@export var move_distance: float`
- Rare for local variables
- Sometimes used for function parameters/returns

**Godot Built-in Types:**
- `Vector3` - 3D vectors
- `float` - Floating point
- `RayCast3D`, `MeshInstance3D` - Node types
- Godot provides type safety for node references via `@onready`

## Node References

**@onready Pattern:**
```gdscript
@onready var wheels = [
	$WheelFL,
	$WheelFR,
	$WheelRL,
	$WheelRR
]

@onready var wheel_meshes = [
	$WheelFL/WheelMeshFL,
	$WheelFR/WheelMeshFR,
	$WheelRL/WheelMeshRL,
	$WheelRR/WheelMeshRR
]
```

**Why @onready:**
- Delays initialization until node is in scene tree
- Ensures child nodes exist before access
- Prevents null reference errors

**Node Path Syntax:**
- `$NodeName` - Direct child
- `$Parent/Child` - Nested path
- Relative to script's attached node

## Exported Variables

**@export Decorator:**
```gdscript
@export var move_distance: float = 20.0
@export var move_speed: float = 5.0
@export var move_axis: Vector3 = Vector3.RIGHT
```

**Purpose:**
- Exposes variables to Godot editor
- Allows per-instance customization in scene editor
- Default values can be overridden in .tscn files

## Physics Conventions

**Coordinate System:**
- +X: Right
- +Y: Up
- +Z: Backward (Godot convention)
- -Z: Forward (car moves in -Z direction)

**Force Application:**
```gdscript
apply_force(force_vector, local_offset_from_center)
```

**Velocity Calculation:**
```gdscript
func get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)
```

**Delta Time:**
- `_physics_process(delta)` - Fixed timestep physics
- `delta` - Time since last physics frame (seconds)
- Used for frame-rate independent calculations: `time += delta * move_speed`

## Input Handling

**Action-Based Input:**
```gdscript
if Input.is_action_pressed("ui_up"):
	throttle += 1.0
if Input.is_action_pressed("ui_left"):
	steer_input += 1.0
```

**Why Actions (not raw keys):**
- Remappable in project settings
- Multi-input support (keyboard + gamepad)
- Godot convention

**Input Locations:**
- `_input(event)` - Event-based (button press)
- `_physics_process(delta)` - Polling (continuous input)

**Event Handling:**
```gdscript
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
```

## Scene Transitions

**Pattern:**
```gdscript
get_tree().change_scene_to_file("res://scenes/menu.tscn")
```

**Characteristics:**
- Uses `res://` protocol for resources
- Unloads current scene
- Loads new scene
- No transition animation (instant)

## Error Handling

**No Explicit Error Handling:**
- No try/catch blocks (GDScript has limited exception support)
- No error checking for null nodes (relies on @onready)
- Physics bounds checking via conditionals:
  ```gdscript
  if abs(global_position.x) > boundary_x or ... or up_dot < 0.3:
      reset_position()
  ```

**Godot Error Reporting:**
- Engine prints errors to console
- Node path errors caught automatically
- Physics collisions don't throw errors (gracefully handled)

## Magic Numbers

**Pattern:** Constants at top of file
```gdscript
const SPRING_STRENGTH = 200.0
const ENGINE_FORCE = 40.0
const REST_LENGTH = 0.6
```

**Some Inline Magic Numbers:**
```gdscript
var boundary_x = 28.0  # Could be extracted
var boundary_z = 38.0
if up_dot < 0.3:       # Flip detection threshold
```

**Improvement Opportunity:** Extract remaining magic numbers to constants.

## Array/Collection Usage

**Literal Arrays:**
```gdscript
@onready var wheels = [
	$WheelFL,
	$WheelFR,
	$WheelRL,
	$WheelRR
]
```

**Iteration:**
```gdscript
for i in range(wheels.size()):
	var wheel: RayCast3D = wheels[i]
	var wheel_mesh: MeshInstance3D = wheel_meshes[i]
	# ...
```

**Why Index-Based:**
- Parallel access to wheels and wheel_meshes
- Need index to determine front/rear wheels: `if i < 2:`

## Function Length

**Short Functions:**
- `_ready()` - 1 line (initialize start position)
- `reset_position()` - 4 lines (reset car state)

**Medium Functions:**
- `_input()` - 2 lines (scene transition on ESC)
- `get_point_velocity()` - 1 line (velocity formula)

**Long Functions:**
- `_physics_process()` - 50+ lines (main physics loop)
  - Handles input, wheel physics, boundary checks
  - Could be refactored into smaller functions

**Refactoring Opportunity:** Break `_physics_process` into:
- `handle_input(delta)`
- `process_wheel_physics(wheel_index, throttle, delta)`
- `check_boundaries()`

## Comments vs Self-Documenting Code

**Current Balance:**
- Section comments: ✓ Good (`# Suspension parameters`)
- Inline comments: Minimal (code mostly self-explanatory)
- Important notes: ✓ Present (`# Godot 3D, negative Z is forward`)
- Function docstrings: ✗ Missing (not GDScript convention)

**Variable Names:** Self-documenting
- `current_steer`, `throttle`, `compression`, `suspension_force`
- Clear without comments

## Godot-Specific Patterns

**Signal Connections (in .tscn):**
```tscn
[connection signal="pressed" from="VBoxContainer/MainSceneButton" to="." method="_on_main_scene_button_pressed"]
```

**Scene Structure Pattern:**
- Root node (typed): `extends RigidBody3D`, `extends AnimatableBody3D`
- Child nodes defined in .tscn
- Script references children via `$` syntax

**Built-in Callbacks:**
- `_ready()` - Called when node enters scene tree
- `_physics_process(delta)` - Called every physics frame (~60Hz)
- `_input(event)` - Called on input events

## Anti-Patterns Avoided

**✓ No Global Variables:**
- All state encapsulated in scripts
- No AutoLoad singletons (not needed for this scale)

**✓ No String Comparisons for Logic:**
- Uses input actions, not raw key strings
- No node lookups by string path (uses $)

**✓ No Premature Optimization:**
- Clear, readable physics code
- No micro-optimizations

**✓ Separation of Concerns:**
- Car physics in car.gd
- Obstacle behavior in moving_obstacle.gd
- Menu logic in menu scene

## Code Quality Notes

**Strengths:**
- Consistent naming conventions
- Good use of constants
- Clear variable names
- Appropriate use of @onready and @export

**Improvement Opportunities:**
- Add type annotations more consistently
- Extract remaining magic numbers
- Refactor long _physics_process function
- Add function docstrings for complex logic

---
*Conventions documented: 2026-03-20*
