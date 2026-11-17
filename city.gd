
extends Node3D

# TRAFFIC CITY 3D
# Version 0.3 - Beautiful City
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
	panel.custom_minimum_size = Vector2(320, 52)
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

	update_status("Creating cars...")
	create_cars()

	city_ready = true

	update_status(
		"City ready | Cars: "
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

	# Sidewalks: short segments between intersections.
	# This avoids covering the asphalt.

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

	# Yellow road markings
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
				Vector3(3.0, 0.02, 0.18),
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

	# Foundation
	make_box(
		Vector3(0, 0.25, 0),
		Vector3(11.0, 0.5, 11.0),
		concrete,
		building
	)

	# Main building
	make_box(
		Vector3(0, height / 2.0 + 0.5, 0),
		Vector3(10.0, height, 10.0),
		color,
		building
	)

	# Roof
	make_box(
		Vector3(0, height + 0.7, 0),
		Vector3(10.5, 0.4, 10.5),
		Color(0.28, 0.32, 0.35),
		building
	)

	# Entrance
	make_box(
		Vector3(0, 1.65, 5.06),
		Vector3(2.3, 2.5, 0.12),
		Color(0.15, 0.27, 0.34),
		building
	)

	# Entrance canopy
	make_box(
		Vector3(0, 3.0, 5.6),
		Vector3(3.2, 0.18, 1.3),
		Color(0.30, 0.34, 0.36),
		building
	)

	# Windows - front and back
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
