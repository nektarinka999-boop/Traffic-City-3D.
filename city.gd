
extends Node3D

var cars: Array[Node3D] = []
var car_speeds: Array[float] = []

func _ready() -> void:
	create_ground()
	create_roads()
	create_buildings()
	create_bridge()
	create_cars()

func make_box(
	pos: Vector3,
	size: Vector3,
	color: Color
) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_node.mesh = mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh_node.material_override = material
	mesh_node.position = pos
	add_child(mesh_node)
	return mesh_node

func create_ground() -> void:
	make_box(
		Vector3(0, -0.2, 0),
		Vector3(120, 0.4, 120),
		Color(0.24, 0.43, 0.25)
	)

func create_roads() -> void:
	var asphalt := Color(0.12, 0.13, 0.15)
	var marking := Color(0.95, 0.85, 0.35)

	for x in [-30.0, 0.0, 30.0]:
		make_box(
			Vector3(x, 0.04, 0),
			Vector3(9, 0.08, 110),
			asphalt
		)

	for z in [-30.0, 0.0, 30.0]:
		make_box(
			Vector3(0, 0.05, z),
			Vector3(110, 0.08, 9),
			asphalt
		)

	for x in [-30.0, 0.0, 30.0]:
		for z in range(-52, 53, 8):
			make_box(
				Vector3(x, 0.11, z),
				Vector3(0.18, 0.02, 3),
				marking
			)

	for z in [-30.0, 0.0, 30.0]:
		for x in range(-52, 53, 8):
			make_box(
				Vector3(x, 0.12, z),
				Vector3(3, 0.02, 0.18),
				marking
			)

func create_buildings() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026

	for x in [-45.0, -15.0, 15.0, 45.0]:
		for z in [-45.0, -15.0, 15.0, 45.0]:
			var height := rng.randf_range(5.0, 19.0)
			var color := Color(
				rng.randf_range(0.35, 0.75),
				rng.randf_range(0.4, 0.75),
				rng.randf_range(0.5, 0.85)
			)
			make_box(
				Vector3(x, height / 2.0, z),
				Vector3(10, height, 10),
				color
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
		var direction := 1.0 if i % 2 == 0 else -1.0

		car.position = Vector3(
			road_x + (2.0 if direction > 0 else -2.0),
			0.65,
			float(i * 9 - 50)
		)

		var body := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(2, 1, 3.8)
		body.mesh = mesh

		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.from_hsv(
			float(i) / 12.0, 0.75, 0.9
		)
		body.material_override = mat
		car.add_child(body)

		var roof := MeshInstance3D.new()
		var roof_mesh := BoxMesh.new()
		roof_mesh.size = Vector3(1.6, 0.65, 2)
		roof.mesh = roof_mesh
		roof.position.y = 0.7
		roof.material_override = mat
		car.add_child(roof)

		cars.append(car)
		car_speeds.append(direction * (5.0 + float(i % 4)))

func _process(delta: float) -> void:
	for i in range(cars.size()):
		var car := cars[i]
		car.position.z += car_speeds[i] * delta

		if car.position.z > 55:
			car.position.z = -55
		elif car.position.z < -55:
			car.position.z = 55
