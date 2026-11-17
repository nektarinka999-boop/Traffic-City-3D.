
extends Camera3D

# TRAFFIC CITY 3D
# Version 0.6 - Free Camera
# Godot 4.3 / Android

# One finger: move around the city
# Two fingers: zoom and rotate
# Double tap: reset camera

const MIN_DISTANCE: float = 25.0
const MAX_DISTANCE: float = 210.0
const MIN_PITCH: float = 20.0
const MAX_PITCH: float = 78.0

const PAN_SPEED: float = 0.0025
const ZOOM_SPEED: float = 0.18
const ROTATE_SPEED: float = 0.006

var target: Vector3 = Vector3.ZERO

var distance: float = 125.0
var yaw: float = 45.0
var pitch: float = 48.0

var touches: Dictionary = {}

var last_pinch_distance: float = 0.0
var last_pinch_angle: float = 0.0

var last_tap_time: int = 0

var home_button: Button


func _ready() -> void:
	current = true

	create_home_button()
	update_camera()

	print("TRAFFIC CITY: Camera control ready")


func create_home_button() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)

	home_button = Button.new()
	home_button.text = "HOME"
	home_button.position = Vector2(20, 90)
	home_button.custom_minimum_size = Vector2(140, 60)

	home_button.add_theme_font_size_override(
		"font_size",
		24
	)

	layer.add_child(home_button)

	home_button.pressed.connect(reset_camera)


func reset_camera() -> void:
	target = Vector3.ZERO

	distance = 125.0
	yaw = 45.0
	pitch = 48.0

	touches.clear()

	last_pinch_distance = 0.0
	last_pinch_angle = 0.0

	update_camera()


func update_camera() -> void:
	var yaw_rad := deg_to_rad(yaw)
	var pitch_rad := deg_to_rad(pitch)

	var horizontal := distance * cos(pitch_rad)
	var vertical := distance * sin(pitch_rad)

	var offset := Vector3(
		sin(yaw_rad) * horizontal,
		vertical,
		cos(yaw_rad) * horizontal
	)

	global_position = target + offset
	look_at(target, Vector3.UP)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		handle_touch(event)

	elif event is InputEventScreenDrag:
		handle_drag(event)

	elif event is InputEventMouseButton:
		handle_mouse_button(event)

	elif event is InputEventMouseMotion:
		handle_mouse_motion(event)


func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		touches[event.index] = event.position

		if touches.size() == 1:
			var now := Time.get_ticks_msec()

			if now - last_tap_time < 350:
				reset_camera()
				last_tap_time = 0
				return

			last_tap_time = now

	else:
		touches.erase(event.index)

	if touches.size() == 2:
		reset_pinch_reference()
	else:
		last_pinch_distance = 0.0
		last_pinch_angle = 0.0


func handle_drag(event: InputEventScreenDrag) -> void:
	if not touches.has(event.index):
		return

	touches[event.index] = event.position

	if touches.size() == 1:
		pan_camera(event.relative)

	elif touches.size() == 2:
		update_pinch()


func pan_camera(relative: Vector2) -> void:
	var camera_right := global_transform.basis.x
	var camera_forward := -global_transform.basis.z

	camera_right.y = 0.0
	camera_forward.y = 0.0

	camera_right = camera_right.normalized()
	camera_forward = camera_forward.normalized()

	var amount := distance * PAN_SPEED

	target -= camera_right * relative.x * amount
	target += camera_forward * relative.y * amount

	target.x = clampf(target.x, -70.0, 70.0)
	target.z = clampf(target.z, -70.0, 70.0)

	update_camera()


func reset_pinch_reference() -> void:
	var positions := touches.values()

	if positions.size() != 2:
		return

	var a: Vector2 = positions[0]
	var b: Vector2 = positions[1]

	last_pinch_distance = a.distance_to(b)
	last_pinch_angle = (b - a).angle()


func update_pinch() -> void:
	var positions := touches.values()

	if positions.size() != 2:
		return

	var a: Vector2 = positions[0]
	var b: Vector2 = positions[1]

	var new_distance := a.distance_to(b)
	var new_angle := (b - a).angle()

	if last_pinch_distance > 0.0:
		var difference := (
			new_distance - last_pinch_distance
		)

		distance -= difference * ZOOM_SPEED

		distance = clampf(
			distance,
			MIN_DISTANCE,
			MAX_DISTANCE
		)

	var angle_difference := wrapf(
		new_angle - last_pinch_angle,
		-PI,
		PI
	)

	yaw += rad_to_deg(
		angle_difference * ROTATE_SPEED * 25.0
	)

	last_pinch_distance = new_distance
	last_pinch_angle = new_angle

	update_camera()


func handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if event.pressed:
			distance = maxf(
				MIN_DISTANCE,
				distance - 8.0
			)
			update_camera()

	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if event.pressed:
			distance = minf(
				MAX_DISTANCE,
				distance + 8.0
			)
			update_camera()


func handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pan_camera(event.relative)

	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * 0.25

		pitch = clampf(
			pitch + event.relative.y * 0.20,
			MIN_PITCH,
			MAX_PITCH
		)

		update_camera()
