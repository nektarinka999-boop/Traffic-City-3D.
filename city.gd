
extends Node3D

# TRAFFIC CITY 3D
# Version 0.2.1 - Android Diagnostics
# Godot 4.3

var cars: Array[Node3D] = []
var car_speeds: Array[float] = []

var debug_label: Label
var debug_layer: CanvasLayer

var created_objects: int = 0
var city_ready: bool = false
var elapsed: float = 0.0

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	print("TRAFFIC CITY: City script started")

	create_debug_overlay()
	update_status("1/6 - City script started")

	# Create the city gradually so the screen can update.
	call_deferred("start_city")


func create_debug_overlay() -> void:
	debug_layer = CanvasLayer.new()
	debug_layer.layer = 10
	add_child(debug_layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(20, 20)
	panel.custom_minimum_size = Vector2(540, 130)
	debug_layer.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.07, 0.10, 0.88)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	panel.add_theme_stylebox_override("panel", style)

	debug_label = Label.new()
	debug_label.add_theme_font_size_override("font_size", 24)
	debug_label.add_theme_color_override(
		"font_color",
		Color(0.45, 1.0, 0.60)
	)

	debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	panel.add_child(debug_label)


func update_status(message: String) -> void:
	print("TRAFFIC CITY: ", message)

	if debug_label != null:
		debug_label.text = (
			"TRAFFIC CITY 3D - DIAGNOSTICS\n"
			+ message
			+ "\nObjects: "
			+ str(created_objects)
		)


func start_city() -> void:
	rng.seed = 2026

	update_status("2/6 - Creating ground")
	create_ground()

	update_status("3/6 - Creating roads")
	create_roads()

	update_status("4/6 - Creating buildings")
	create_buildings()

	update_status("5/6 - Creating bridge")
	create_bridge()

	update_status("6/6 - Creating cars")
	create_cars()

	city_ready = true

	update_status("SUCCESS - City created!")

	print(
		"TRAFFIC CITY: Complete. Objects: ",
		created_objects
	)


func make_box(
	pos: Vector3,
	size: Vector3,
	color: Color,
	parent: Node3D = null
) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()

	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_node.mesh = mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8

	mesh_node.material_override = material
	mesh_node.position = pos

	if parent == null:
		add_child(mesh_node)
	else:
		parent.add_child(mesh_node)

	created_objects += 1

	return mesh_node


func create_ground() -> void:
	make_box(
		Vector3(0, -0.2, 0),
		Vector3(120, 0.4, 120),
		Color(0.25, 0.48, 0.29)
	)


func create_roads() -> void:
	var asphalt := Color(0.11, 0.13, 0.15)
	var marking := Color(0.96, 0.82, 0.32)

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

	for x in [-30.0, 0.0, 30.0]:
		for z in range(-52, 53, 8):
			make_box(
				Vector3(x, 0.12, float(z)),
				Vector3(0.18, 0.02, 3),
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
	var colors := [
		Color(0.65, 0.73, 0.78),
		Color(0.79, 0.67, 0.59),
		Color(0.67, 0.76, 0.66),
		Color(0.73, 0.67, 0.80)
	]

	for x in [-45.0, -15.0, 15.0, 45.0]:
		for z in [-45.0, -15.0, 15.0, 45.0]:
			var height := rng.randf_range(7.0, 20.0)
			var index := rng.randi_range(
				0, colors.size() - 1
			)

			make_box(
				Vector3(x, height / 2.0, z),
				Vector3(10, height, 10),
				colors[index]
			)

			# A few windows to test materials
			for floor_index in range(3):
				var y := 2.5 + float(floor_index) * 3.0

				if y >= height:
					continue

				for column in range(2):
					var window_x := (
						-2.5 + float(column) * 5.0
					)

					make_box(
						Vector3(x + window_x, y, z + 5.05),
						Vector3(2.0, 1.4, 0.1),
						Color(0.20, 0.36, 0.48)
					)


func create_bridge() -> void:
	var concrete := Color(0.55, 0.58, 0.61)
	var bridge_road := Color(0.18, 0.19, 0.22)

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

		var car_color := Color.from_hsv(
			float(i) / 12.0,
			0.75,
			0.9
		)

		make_box(
			Vector3.ZERO,
			Vector3(2.0, 1.0, 3.8),
			car_color,
			car
		)

		make_box(
			Vector3(0, 0.7, 0),
			Vector3(1.6, 0.65, 2.0),
			Color(0.15, 0.28, 0.37),
			car
		)

		cars.append(car)

		car_speeds.append(
			direction * (5.0 + float(i % 4))
		)


func _process(delta: float) -> void:
	elapsed += delta

	if city_ready:
		for i in range(cars.size()):
			var car := cars[i]

			car.position.z += car_speeds[i] * delta

			if car.position.z > 55.0:
				car.position.z = -55.0

			elif car.position.z < -55.0:
				car.position.z = 55.0

	# Update diagnostics once per second.
	if elapsed >= 1.0:
		elapsed = 0.0

		if city_ready:
			update_status(
				"SUCCESS - City running!\nCars: "
				+ str(cars.size())
			)
