extends RigidBody3D

## Reference to the Ocean node, which provides the water surface height
## at a given global position through its get_height() method.
@export var ocean: Node3D

## Depth required for a buoyancy point to reach maximum submersion.
@export var full_submersion_depth: float = 1.0

## Multiplier controlling the strength of the buoyancy force.
@export var buoyancy_strength: float = 1.0

## Strength of linear water resistance.
@export var water_drag: float = 1.5

## Strength of rotational water resistance.
@export var water_angular_drag: float = 2.0

## Minimum number of submerged float points required to apply water drag.
@export var drag_activation_threshold: int = 1


## Reference to the child node containing all buoyancy point markers.
@onready var float_points: Node3D = $FloatPoints

var _points: Array[Node3D] = []
var _floaters: int = 0

# Gravity strength retrieved from the project's physics settings
var gravity_strength: float = 9.8


func _ready() -> void:
	# Read the gravity strength configured in the project settings
	gravity_strength = float(
		ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	)

	# Report an error if the Ocean node could not be found
	if ocean == null:
		push_error("Ocean node could not be found.")
		return

	# Disable built-in gravity because gravity is applied manually
	gravity_scale = 0.0

	if drag_activation_threshold <= 0:
		push_warning("Drag activation threshold is set to 0 or below. This will cause water drag to never be applied.")

	# Collect all valid buoyancy points.
	for child in float_points.get_children():
		if child is Node3D:
			_points.append(child)

	# Count the buoyancy points to distribute the object's weight
	_floaters = _points.size()

	# Push error if there are no float points
	if _floaters <= 0:
		push_error("No float points found. Please add at least one child node to the FloatPoints node.")

	# Warn the user if there are not enough float points to activate water drag
	if _floaters < drag_activation_threshold:
		push_warning("Not enough float points to activate water drag. This will cause water drag to never be applied.")

func _physics_process(delta: float) -> void:
	# Stop the physics calculations if the Ocean reference is missing
	if ocean == null:
		return

	# Count how many buoyancy points are currently submerged
	var submerged_count: int = 0

	# Calculate gravity and buoyancy independently at each point
	for point in _points:
		# Get the buoyancy point's position in global coordinates
		var point_position: Vector3 = point.global_position

		# Calculate the offset from the body origin to the buoyancy point
		var force_offset: Vector3 = point_position - global_position

		# Get the water surface height at the current global position
		var water_height: float = ocean.get_height(point_position)

		# Calculate the depth below the water surface
		var depth: float = water_height - point_position.y

		# Distribute the object's weight across all buoyancy points
		var gravity_force: Vector3 = (
			Vector3.DOWN * gravity_strength * mass / _floaters
		)
		apply_force(gravity_force, force_offset)

		# Apply buoyancy only when the point is underwater
		if depth > 0.0:
			submerged_count += 1

			# Calculate the normalized submersion ratio
			var submersion: float = clampf(
				depth / maxf(full_submersion_depth, 0.001),
				0.0,
				1.0
			)

			# Calculate the upward buoyancy acceleration
			var buoyancy_acceleration: float = (
				gravity_strength * submersion * buoyancy_strength
			)

			# Convert acceleration into force using the body's mass
			var buoyancy_force: Vector3 = (
				Vector3.UP * buoyancy_acceleration * mass
			)

			# Apply buoyancy at the buoyancy point's position
			apply_force(buoyancy_force, force_offset)

	# Apply water resistance if at least one point is submerged
	if submerged_count >= drag_activation_threshold:
		# Calculate the fraction of linear velocity removed this frame
		var drag_factor: float = clampf(
			water_drag * delta,
			0.0,
			1.0
		)

		# Calculate the fraction of angular velocity removed this frame
		var angular_drag_factor: float = clampf(
			water_angular_drag * delta,
			0.0,
			1.0
		)

		# Reduce linear velocity to simulate water resistance
		linear_velocity *= 1.0 - drag_factor

		# Reduce angular velocity to simulate rotational resistance
		angular_velocity *= 1.0 - angular_drag_factor
