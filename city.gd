
extends Node3D

# TRAFFIC CITY 3D
# Version 0.2 - Graphics Update
# Godot 4.3 / Android

var cars: Array[Node3D] = []
var car_speeds: Array[float] = []

var rng := RandomNumberGenerator.new()

var asphalt := Color(0.105, 0.12, 0.14)
var sidewalk := Color(0.68, 0.69, 0.66)
var concrete := Color(0.52, 0.55, 0.57)
var grass := Color(0.26, 0.48, 0.29)
var white_line := Color(0.92, 0.92, 0.86)
var yellow_line := Color(0.96, 0.78, 0.29)

var glass_colors := [
	Color(0.19, 0.33, 0.43),
	Color(0.26, 0.43, 0.54),
	Color(0.38, 0.51, 0.59)
]

var building_colors := [
	Color(0.72, 0.74, 0.73),
	Color(0.77, 0.67, 0.60),
	Color(0.62, 0.70, 0.75),
	Color(0.81, 0.77, 0.68),
	Color(0.57, 0.65, 0.68),
	Color(0.72, 0.64, 0.72)
]


func _ready() -> void:
	rng.seed = 2026

	create_ground()
	create_roads()
	create_buildings()
	create_bridge()
	create_parks()
	create_street_lights()
	create_cars()


func make_box(
	pos: Vector3,
	size: Vector3,
	color: Color,
	parent: Node3D = null,
	metallic: float = 0.0,
	roughness: float = 0.8
) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()

	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_node.mesh = mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness

	mesh_node.material_override = material
	mesh_node.position = pos

	if parent == null:
		add_child(mesh_node)
	else:
		parent.add_child(mesh_node)

	return mesh_node


func make_cylinder(
	pos: Vector3,
	radius: float,
	height: float,
	color: Color,
	parent: Node3D = null
) -> MeshInstance3D:
	var node := MeshInstance3D.new()

	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8

	node.mesh = mesh
	node.position = pos

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	node.material_override = material

	if parent == null:
		add_child(node)
	else:
		parent.add_child(node)

	return node


func make_sphere(
	pos: Vector3,
	radius: float,
	color: Color,
	parent: Node3D = null
) -> MeshInstance3D:
	var node := MeshInstance3D.new()

	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4

	node.mesh = mesh
	node.position = pos

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	node.material_override = material

	if parent == null:
		add_child(node)
	else:
		parent.add_child(node)

	return node


func create_ground() -> void:
	make_box(
		Vector3(0, -0.25, 0),
		Vector3(120, 0.5, 120),
		grass
	)


func create_roads() -> void:
	for x in [-30.0, 0.0, 30.0]:
		make_box(
			Vector3(x, 0.06, 0),
			Vector3(9.0, 0.12, 110),
			asphalt
		)

	for z in [-30.0, 0.0, 30.0]:
		make_box(
			Vector3(0, 0.065, z),
			Vector3(110, 0.12, 9.0),
			asphalt
		)

	# Pavements along the roads
	for x in [-30.0, 0.0, 30.0]:
		for side in [-1.0, 1.0]:
			make_box(
				Vector3(x + side * 5.4, 0.12, 0),
				Vector3(1.6, 0.24, 110),
				sidewalk
			)

	for z in [-30.0, 0.0, 30.0]:
		for side in [-1.0, 1.0]:
			make_box(
				Vector3(0, 0.12, z + side * 5.4),
				Vector3(110, 0.24, 1.6),
				sidewalk
			)

	# Restore asphalt over pavement intersections
	for x in [-30.0, 0.0, 30.0]:
		for z in [-30.0, 0.0, 30.0]:
			make_box(
				Vector3(x, 0.20, z),
				Vector3(9.0, 0.04, 9.0),
				asphalt
			)

	# Road markings
	for x in [-30.0, 0.0, 30.0]:
		for z in range(-52, 53, 8):
			if is_near_intersection(float(z)):
				continue

			make_box(
				Vector3(x, 0.14, float(z)),
				Vector3(0.16, 0.02, 3.0),
				yellow_line
			)

	for z in [-30.0, 0.0, 30.0]:
		for x in range(-52, 53, 8):
			if is_near_intersection(float(x)):
				continue

			make_box(
				Vector3(float(x), 0.14, z),
				Vector3(3.0, 0.02, 0.16),
				yellow_line
			)

	# White edge lines
	for x in [-30.0, 0.0, 30.0]:
		for side in [-1.0, 1.0]:
			make_box(
				Vector3(x + side * 4.1, 0.14, 0),
				Vector3(0.12, 0.02, 110),
				white_line
			)

	for z in [-30.0, 0.0, 30.0]:
		for side in [-1.0, 1.0]:
			make_box(
				Vector3(0, 0.14, z + side * 4.1),
				Vector3(110, 0.02, 0.12),
				white_line
			)


func is_near_intersection(value: float) -> bool:
	for center in [-30.0, 0.0, 30.0]:
		if absf(value - center) < 7.0:
			return true

	return false


func create_buildings() -> void:
	for x in [-45.0, -15.0, 15.0, 45.0]:
		for z in [-45.0, -15.0, 15.0, 45.0]:
			var height := rng.randf_range(9.0, 23.0)
			var color_index := rng.randi_range(
				0, building_colors.size() - 1
			)

			create_detailed_building(
				Vector3(x, 0, z),
				height,
				building_colors[color_index]
			)


func create_detailed_building(
	pos: Vector3,
	height: float,
	color: Color
) -> void:
	var building := Node3D.new()
	building.position = pos
	add_child(building)

	# Foundation
	make_box(
		Vector3(0, 0.3, 0),
		Vector3(12.5, 0.6, 12.5),
		concrete,
		building
	)

	# Main structure
	make_box(
		Vector3(0, height / 2.0 + 0.6, 0),
		Vector3(10.0, height, 10.0),
		color,
		building
	)

	# Roof
	make_box(
		Vector3(0, height + 0.85, 0),
		Vector3(10.8, 0.5, 10.8),
		Color(0.27, 0.30, 0.34),
		building
	)

	# Roof utility box
	make_box(
		Vector3(-2.0, height + 1.4, 0),
		Vector3(2.5, 0.8, 3.0),
		Color(0.48, 0.50, 0.52),
		building
	)

	var glass := glass_colors[
		rng.randi_range(0, glass_colors.size() - 1)
	]

	var floor_count := int(height / 3.2)

	for floor_index in range(floor_count):
		var window_y := 2.5 + float(floor_index) * 3.1

		if window_y > height:
			continue

		for column in range(3):
			var offset := -3.1 + float(column) * 3.1

			# Front
			make_box(
				Vector3(offset, window_y, 5.04),
				Vector3(1.8, 1.5, 0.08),
				glass,
				building,
				0.25,
				0.2
			)

			# Back
			make_box(
				Vector3(offset, window_y, -5.04),
				Vector3(1.8, 1.5, 0.08),
				glass,
				building,
				0.25,
				0.2
			)

			# Left
			make_box(
				Vector3(-5.04, window_y, offset),
				Vector3(0.08, 1.5, 1.8),
				glass,
				building,
				0.25,
				0.2
			)

			# Right
			make_box(
				Vector3(5.04, window_y, offset),
				Vector3(0.08, 1.5, 1.8),
				glass,
				building,
				0.25,
				0.2
			)

	# Entrance
	make_box(
		Vector3(0, 1.7, 5.1),
		Vector3(2.4, 2.7, 0.15),
		Color(0.13, 0.22, 0.28),
		building
	)

	# Entrance canopy
	make_box(
		Vector3(0, 3.1, 5.6),
		Vector3(3.5, 0.2, 1.5),
		Color(0.30, 0.33, 0.35),
		building
	)


func create_bridge() -> void:
	var bridge_road := Color(0.17, 0.19, 0.21)

	# Deck
	make_box(
		Vector3(0, 5, -15),
		Vector3(10, 0.8, 28),
		bridge_road
	)

	# Supports
	for z in [-26.0, -4.0]:
		for x in [-4.0, 4.0]:
			make_box(
				Vector3(x, 2.5, z),
				Vector3(0.9, 5.0, 0.9),
				concrete
			)

	# Guardrails
	for x in [-5.0, 5.0]:
		make_box(
			Vector3(x, 5.8, -15),
			Vector3(0.25, 1.0, 28),
			concrete
		)

	# Bridge center line
	for z in range(-26, -3, 6):
		make_box(
			Vector3(0, 5.43, float(z)),
			Vector3(0.16, 0.02, 2.8),
			yellow_line
		)

	# Bridge edge markings
	for x in [-4.3, 4.3]:
		make_box(
			Vector3(x, 5.43, -15),
			Vector3(0.12, 0.02, 27),
			white_line
		)


func create_parks() -> void:
	for x in [-45.0, -15.0, 15.0, 45.0]:
		for z in [-45.0, -15.0, 15.0, 45.0]:
			# Small trees around building plots
			create_tree(Vector3(x - 8.0, 0, z - 8.0))
			create_tree(Vector3(x + 8.0, 0, z + 8.0))

	# Green corners
	for x in [-54.0, 54.0]:
		for z in [-54.0, 54.0]:
			create_tree(Vector3(x, 0, z))
			create_tree(Vector3(x + signf(-x) * 3.0, 0, z))


func create_tree(pos: Vector3) -> void:
	var tree := Node3D.new()
	tree.position = pos
	add_child(tree)

	# Trunk
	make_cylinder(
		Vector3(0, 1.25, 0),
		0.3,
		2.5,
		Color(0.36, 0.24, 0.15),
		tree
	)

	# Crown
	var green := Color(
		rng.randf_range(0.17, 0.25),
		rng.randf_range(0.42, 0.60),
		rng.randf_range(0.19, 0.29)
	)

	make_sphere(
		Vector3(0, 3.5, 0),
		1.7,
		green,
		tree
	)

	make_sphere(
		Vector3(-0.8, 3.0, 0),
		1.1,
		green,
		tree
	)

	make_sphere(
		Vector3(0.7, 3.1, 0.4),
		1.1,
		green,
		tree
	)


func create_street_lights() -> void:
	for x in [-30.0, 0.0, 30.0]:
		for z in [-45.0, -15.0, 15.0, 45.0]:
			create_street_light(
				Vector3(x + 6.8, 0, z)
			)

	for z in [-30.0, 0.0, 30.0]:
		for x in [-45.0, -15.0, 15.0, 45.0]:
			create_street_light(
				Vector3(x, 0, z + 6.8)
			)


func create_street_light(pos: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.position = pos
	add_child(lamp)

	var dark_metal := Color(0.22, 0.25, 0.28)

	make_cylinder(
		Vector3(0, 2.5, 0),
		0.10,
		5.0,
		dark_metal,
		lamp
	)

	make_box(
		Vector3(0.55, 4.95, 0),
		Vector3(1.2, 0.12, 0.12),
		dark_metal,
		lamp
	)

	make_box(
		Vector3(1.0, 4.85, 0),
		Vector3(0.7, 0.12, 0.45),
		Color(1.0, 0.91, 0.65),
		lamp
	)


func create_cars() -> void:
	for i in range(12):
		var car := Node3D.new()
		add_child(car)

		var lane := i % 3
		var road_x := float(lane - 1) * 30.0
		var direction := 1.0 if i % 2 == 0 else -1.0

		car.position = Vector3(
			road_x + (
				2.0 if direction > 0.0 else -2.0
			),
			0.75,
			float(i * 9 - 50)
		)

		# Car front is local -Z
		if direction > 0.0:
			car.rotation.y = PI

		var car_color := Color.from_hsv(
			float(i) / 12.0,
			0.65,
			0.9
		)

		create_detailed_car(car, car_color)

		cars.append(car)
		car_speeds.append(
			direction * (5.0 + float(i % 4))
		)


func create_detailed_car(
	car: Node3D,
	color: Color
) -> void:
	var glass := Color(0.12, 0.22, 0.30)
	var tire := Color(0.055, 0.06, 0.065)
	var light := Color(1.0, 0.95, 0.72)
	var red_light := Color(0.85, 0.12, 0.09)

	# Lower body
	make_box(
		Vector3(0, 0, 0),
		Vector3(2.1, 0.75, 4.0),
		color,
		car,
		0.15,
		0.35
	)

	# Cabin
	make_box(
		Vector3(0, 0.68, 0.1),
		Vector3(1.75, 0.75, 2.2),
		glass,
		car,
		0.25,
		0.15
	)

	# Roof
	make_box(
		Vector3(0, 1.08, 0.1),
		Vector3(1.65, 0.12, 1.85),
		color,
		car
	)

	# Front hood
	make_box(
		Vector3(0, 0.39, -1.5),
		Vector3(1.95, 0.12, 0.9),
		color,
		car
	)

	# Headlights
	for x in [-0.75, 0.75]:
		make_box(
			Vector3(x, 0.05, -2.03),
			Vector3(0.42, 0.23, 0.08),
			light,
			car
		)

		# Tail lights
		make_box(
			Vector3(x, 0.05, 2.03),
			Vector3(0.42, 0.22, 0.08),
			red_light,
			car
		)

	# Wheels
	for x in [-1.06, 1.06]:
		for z in [-1.25, 1.25]:
			var wheel := make_cylinder(
				Vector3(x, -0.36, z),
				0.48,
				0.28,
				tire,
				car
			)

			wheel.rotation.z = PI / 2.0

	# Front and rear bumpers
	make_box(
		Vector3(0, -0.23, -2.03),
		Vector3(1.85, 0.18, 0.12),
		Color(0.17, 0.19, 0.21),
		car
	)

	make_box(
		Vector3(0, -0.23, 2.03),
		Vector3(1.85, 0.18, 0.12),
		Color(0.17, 0.19, 0.21),
		car
	)


func _process(delta: float) -> void:
	for i in range(cars.size()):
		var car := cars[i]

		car.position.z += car_speeds[i] * delta

		if car.position.z > 55.0:
			car.position.z = -55.0

		elif car.position.z < -55.0:
			car.position.z = 55.0
