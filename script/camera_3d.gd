extends Camera3D

@export var mouse_sensitivity := 0.002
@export var movement_speed := 100.0
@export var fast_speed_multiplier := 25.0
@export var low_speed_multiplier := 0.1

var _mouse_captured := false
var _total_pitch := 0.0


func _ready() -> void:
	self.set_far(100000)
	pass
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_mouse_capture()
	
	if not _mouse_captured:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		var pitch = -event.relative.y * mouse_sensitivity
		_total_pitch = clamp(_total_pitch + pitch, -PI/2, PI/2)
		rotation.x = _total_pitch

func _physics_process(delta: float) -> void:
	if not _mouse_captured:
		return
	
	var input_dir := Vector3.ZERO
	var speed_multiplier := 1.0
	
	if Input.is_key_pressed(KEY_Z):
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_key_pressed(KEY_Q):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_E):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_ALT):
		speed_multiplier = low_speed_multiplier
	if Input.is_key_pressed(KEY_SHIFT):
		speed_multiplier = fast_speed_multiplier
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		var movement := transform.basis * input_dir
		position += movement * movement_speed * speed_multiplier * delta
	


func _toggle_mouse_capture() -> void:
	_mouse_captured = not _mouse_captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _mouse_captured else Input.MOUSE_MODE_VISIBLE
