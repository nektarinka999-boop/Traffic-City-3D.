
extends Node3D

# TRAFFIC CITY 3D
# Version 0.4 - Green City
# Godot 4.3 / Android

var cars: Array[Node3D] = []
var car_speeds: Array[float] = []

var rng := RandomNumberGenerator.new()

var created_objects: int = 0
var city_ready: bool = false

var debug_label: Label

var asphalt := Color(0.11, 0.13, 0.15)
var sidewalk := Color(0.69, 0.70, 0.68)
var concrete := Color(0.55, 0.58, 0.61)
var grass := Color(0.25, 0.48, 0.29)
var marking := Color(0.96, 0.82, 0.32)

var building_colors := [
	Color(0.73, 0.76, 0.77),
	Color(0.81, 0.69, 0.61),
	Color(0.68, 0.78, 0.69),
	Color(0.77, 0.70, 0.82),
	Color(0.66, 0.74, 0.81),
	Color(0.84, 0.80, 0.69)
]


func _ready() -> void:
	rng.seed = 2026
	create_debug_indicator()
	call_deferred("start_city")


func create_debug_indicator() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(15, 15)
	panel.custom_minimum_size = Vector2(360, 52)
	layer.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.09, 0.12, 0.85)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)

	debug_label = Label.new()
	debug_label.text = "TRAFFIC CITY 3D - Loading..."
	debug_label.add_theme_font_size_override(
		"font_size", 19
	)
	debug_label.add_theme_color_override(
		"font_color",
		Color(0.50, 1.0, 0.65)
	)
	panel.add_child(debug_label)


func update_status(message: String) -> void:
	print("TRAFFIC CITY: ", message)

	if debug_label != null:
		debug_label.text = message


func start_city() -> void:
	update_status("Creating ground...")
	create_ground()

	update_status("Creating roads...")
	create_roads()

	update_status("Creating buildings...")
	create_buildings()

	update_status("Creating bridge...")
	create_bridge()

	update_status("Creating green areas...")
	create_green_areas()

	update_status("Creating street lights...")
	create_street_lights()

	update_status("Creating cars...")
	create_cars()

	city_ready = true

	update_status(
		"Green City ready | Cars: "
		+ str(cars.size())
		+ " | Objects: "
		+ str(created_objects)
	)


func make_box(
	pos: Vector3,
	size: Vector3,
	color: Color,
	parent: Node3D = null
) -> MeshInstance3D:
	var node := MeshInstance3D.new()

	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.75
	node.material_override = material

	node.position = pos

	if parent == null:
		add_child(node)
	else:
		parent.add_child(node)

	created_objects += 1
	return node


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
	material.roughness = 0.85
	node.material_override = material

	if parent == null:
		add_child(node)
	else:
		parent.add_child(node)

	created_objects += 1
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

	created_objects += 1
	return node


func create_ground() -> void:
	make_box(
		Vector3(0, -0.2, 0),
		Vector3(120, 0.4, 120),
		grass
	)


func create_roads() -> void:
	for x in [-30.0, 0.0, 30.0]:
		make_box(
			Vector3(x, 0.05, 0),
			Vector3(9, 0.1, 110),
			asphalt
		)

	for z in [-30.0, 0.0, 30.0]:
		make_box(
			Vector3(0, 0.06, z),
			Vector3(110, 0.1, 9),
			asphalt
		)

	var sidewalk_positions := [
		-45.0, -15.0, 15.0, 45.0
	]

	for x in [-30.0, 0.0, 30.0]:
		for z in sidewalk_positions:
			for side in [-1.0, 1.0]:
				make_box(
					Vector3(x + side * 5.5, 0.12, z),
					Vector3(1.6, 0.24, 19.0),
					sidewalk
				)

	for z in [-30.0, 0.0, 30.0]:
		for x in sidewalk_positions:
			for side in [-1.0, 1.0]:
				make_box(
					Vector3(x, 0.12, z + side * 5.5),
					Vector3(19.0, 0.24, 1.6),
					sidewalk
				)

	for x in [-30.0, 0.0, 30.0]:
		for z in range(-52, 53, 8):
			make_box(
				Vector3(x, 0.12, float(z)),
				Vector3(0.18, 0.02, 3.0),
				marking
			)

	for z in [-30.0, 0.0, 30.0]:
		for x in range(-52, 53, 8):
			make_box(
				Vector3(float(x), 0.13, z),
				Vector3(3, 0.02, 0.18),
				marking
			)


func create_buildings() -> void:
	for x in [-45.0, -15.0, 15.0, 45.0]:
		for z in [-45.0, -15.0, 15.0, 45.0]:
			var height := rng.randf_range(
				8.0, 21.0
			)

			var color_index := rng.randi_range(
				0,
				building_colors.size() - 1
			)

			create_building(
				Vector3(x, 0, z),
				height,
				building_colors[color_index]
			)


func create_building(
	pos: Vector3,
	height: float,
	color: Color
) -> void:
	var building := Node3D.new()
	building.position = pos
	add_child(building)

	make_box(
		Vector3(0, 0.25, 0),
		Vector3(11.0, 0.5, 11.0),
		concrete,
		building
	)

	make_box(
		Vector3(0, height / 2.0 + 0.5, 0),
		Vector3(10.0, height, 10.0),
		color,
		building
	)

	make_box(
		Vector3(0, height + 0.7, 0),
		Vector3(10.5, 0.4, 10.5),
		Color(0.28, 0.32, 0.35),
		building
	)

	make_box(
		Vector3(0, 1.65, 5.06),
		Vector3(2.3, 2.5, 0.12),
		Color(0.15, 0.27, 0.34),
		building
	)

	make_box(
		Vector3(0, 3.0, 5.6),
		Vector3(3.2, 0.18, 1.3),
		Color(0.30, 0.34, 0.36),
		building
	)

	var floor_count := int(height / 3.0)

	for floor_index in range(floor_count):
		var y := 2.5 + float(floor_index) * 3.0

		if y >= height:
			continue

		for column in range(3):
			var window_x := (
				-3.0 + float(column) * 3.0
			)

			var glass := Color(
				0.20, 0.37, 0.49
			)

			make_box(
				Vector3(window_x, y, 5.06),
				Vector3(1.7, 1.45, 0.1),
				glass,
				building
			)

			make_box(
				Vector3(window_x, y, -5.06),
				Vector3(1.7, 1.45, 0.1),
				glass,
				building
			)


func create_bridge() -> void:
	var bridge_road := Color(
		0.18, 0.19, 0.22
	)

	make_box(
		Vector3(0, 5, -15),
		Vector3(10, 0.8, 28),
		bridge_road
	)

	for z in [-26.0, -4.0]:
		for x in [-4.0, 4.0]:
			make_box(
				Vector3(x, 2.5, z),
				Vector3(0.8, 5, 0.8),
				concrete
			)

	for x in [-5.0, 5.0]:
		make_box(
			Vector3(x, 5.8, -15),
			Vector3(0.3, 1, 28),
			concrete
		)


func create_green_areas() -> void:
	# 16 trees, placed near building corners.
	# Avoid roads and sidewalks.

	for x in [-45.0, -15.0, 15.0, 45.0]:
		for z in [-45.0, -15.0, 15.0, 45.0]:
			create_tree(
				Vector3(x + 9.0, 0, z + 9.0)
			)

	# Four small flower beds in the outer corners.
	for x in [-54.0, 54.0]:
		for z in [-54.0, 54.0]:
			create_flower_bed(Vector3(x, 0, z))


func create_tree(pos: Vector3) -> void:
	var tree := Node3D.new()
	tree.position = pos
	add_child(tree)

	var trunk_color := Color(
		0.37, 0.25, 0.16
	)

	var leaf_color := Color(
		rng.randf_range(0.16, 0.24),
		rng.randf_range(0.43, 0.59),
		rng.randf_range(0.18, 0.29)
	)

	make_cylinder(
		Vector3(0, 1.2, 0),
		0.28,
		2.4,
		trunk_color,
		tree
	)

	make_sphere(
		Vector3(0, 3.25, 0),
		1.45,
		leaf_color,
		tree
	)

	make_sphere(
		Vector3(-0.65, 2.9, 0),
		0.85,
		leaf_color,
		tree
	)


func create_flower_bed(pos: Vector3) -> void:
	var bed := Node3D.new()
	bed.position = pos
	add_child(bed)

	make_box(
		Vector3(0, 0.08, 0),
		Vector3(5.0, 0.16, 5.0),
		Color(0.22, 0.35, 0.20),
		bed
	)

	for x in [-1.4, 0.0, 1.4]:
		for z in [-1.4, 0.0, 1.4]:
			var flower_color := Color.from_hsv(
				rng.randf(),
				0.75,
				0.95
			)

			make_sphere(
				Vector3(x, 0.35, z),
				0.32,
				flower_color,
				bed
			)


func create_street_lights() -> void:
	# 12 street lights total.
	for x in [-30.0, 0.0, 30.0]:
		for z in [-45.0, -15.0, 15.0, 45.0]:
			create_street_light(
				Vector3(x + 7.0, 0, z)
			)


func create_street_light(pos: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.position = pos
	add_child(lamp)

	var metal := Color(
		0.22, 0.25, 0.28
	)

	make_cylinder(
		Vector3(0, 2.4, 0),
		0.10,
		4.8,
		metal,
		lamp
	)

	make_box(
		Vector3(0.5, 4.75, 0),
		Vector3(1.0, 0.12, 0.12),
		metal,
		lamp
	)

	make_box(
		Vector3(0.9, 4.65, 0),
		Vector3(0.55, 0.12, 0.45),
		Color(1.0, 0.92, 0.68),
		lamp
	)


func create_cars() -> void:
	for i in range(12):
		var car := Node3D.new()
		add_child(car)

		var lane := i % 3
		var road_x := float(lane - 1) * 30.0

		var direction := (
			1.0 if i % 2 == 0 else -1.0
		)

		car.position = Vector3(
			road_x + (
				2.0 if direction > 0.0 else -2.0
			),
			0.65,
			float(i * 9 - 50)
		)

		var color := Color.from_hsv(
			float(i) / 12.0,
			0.75,
			0.9
		)

		make_box(
			Vector3.ZERO,
			Vector3(2.0, 1.0, 3.8),
			color,
			car
		)

		make_box(
			Vector3(0, 0.7, 0),
			Vector3(1.6, 0.65, 2.0),
			Color(0.16, 0.29, 0.39),
			car
		)

		cars.append(car)

		car_speeds.append(
			direction * (
				5.0 + float(i % 4)
			)
		)


func _process(delta: float) -> void:
	if not city_ready:
		return

	for i in range(cars.size()):
		var car := cars[i]

		car.position.z += car_speeds[i] * delta

		if car.position.z > 55.0:
			car.position.z = -55.0

		elif car.position.z < -55.0:
			car.position.z = 55.0
