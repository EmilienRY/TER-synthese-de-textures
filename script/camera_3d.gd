extends Camera3D

@export var mouse_sensitivity := 0.002
@export var movement_speed := 100.0
@export var fast_speed_multiplier := 25.0
@export var low_speed_multiplier := 0.1
@export var target_meshes: Array[MeshInstance3D]
@export var textures: Array[Texture2D] 

var _mouse_captured := false
var _total_pitch := 0.0
var current_index = 0
var current_texture_index = 0
var patchScale = 0.0

var positions = [
	Vector3(11169.6, 1216.6, -1379.3),  # texBase
	Vector3(18728.951, 1216.6, -1379.3), # fractal
	Vector3(13698.2, 1216.6, -1379.3),  # pavage et mélange
	Vector3(16224.6, 1216.6, -1379.3)   # combinaison
]




func _ready() -> void:
	self.set_far(100000)
	pass
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_mouse_capture()

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			change_texture()
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_RIGHT:
			current_index = (current_index + 1) % positions.size()
			move_camera()
		elif event.keycode == KEY_LEFT:
			current_index = (current_index - 1 + positions.size()) % positions.size()
			move_camera()
	
	if not _mouse_captured:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		var pitch = -event.relative.y * mouse_sensitivity
		_total_pitch = clamp(_total_pitch + pitch, -PI/2, PI/2)
		rotation.x = _total_pitch

func _physics_process(delta: float) -> void:
	
	if Input.is_key_pressed(KEY_PLUS) or Input.is_key_pressed(KEY_KP_ADD): 
		patchScale += 0.2 * delta * 60
		changePatchScale();
	if Input.is_key_pressed(KEY_MINUS) or Input.is_key_pressed(KEY_KP_SUBTRACT): 
		patchScale -= 0.2 * delta * 60
		changePatchScale();
	
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
	
func move_camera():
	position.x = positions[current_index].x
	position.z = positions[current_index].z
	
	
func get_image_data(tex: Texture2D) -> Image:
	var img := tex.get_image()
	if img.is_compressed():
		img.decompress()
	var copy := img.duplicate()
	copy.convert(Image.FORMAT_RGBA8)  # assure un format non compressé et accessible
	return copy


	
func compute_mean(img: Image) -> Color:
	var sum = Color()
	var w = img.get_width()
	var h = img.get_height()
	
	for y in h:
		for x in w:
			sum += img.get_pixel(x, y)
	
	return sum / float(w * h)

func compute_acf(img: Image, max_offset: int = 64) -> Dictionary:
	var mean = compute_mean(img)
	var w = img.get_width()
	var h = img.get_height()
	var acf = {}
	
	for dy in range(-max_offset, max_offset + 1):
		for dx in range(-max_offset, max_offset + 1):
			var cov = 0.0
			var count = 0
			for y in range(h):
				var y2 = y + dy
				if y2 < 0 or y2 >= h:
					continue
				for x in range(w):
					var x2 = x + dx
					if x2 < 0 or x2 >= w:
						continue
					var c1 = img.get_pixel(x, y) - mean
					var c2 = img.get_pixel(x2, y2) - mean
					cov += c1.r * c2.r + c1.g * c2.g + c1.b * c2.b
					count += 1
			if count > 0:
				cov /= count
				acf[Vector2(dx, dy)] = cov
	return acf

func visualize_acf(acf: Dictionary, max_offset: int) -> ImageTexture:
	var size = max_offset * 2 + 1
	var img := Image.create(size, size, false, Image.FORMAT_RGB8)

	var min_val = INF
	var max_val = -INF
	for val in acf.values():
		min_val = min(min_val, val)
		max_val = max(max_val, val)
	
	var scale = 1.0 / (max_val - min_val + 1e-6)

	for dx in range(-max_offset, max_offset + 1):
		for dy in range(-max_offset, max_offset + 1):
			var pos = Vector2(dx, dy)
			if acf.has(pos):
				var val = (acf[pos] - min_val) * scale
				var color = Color(val, val, val)
				img.set_pixel(dx + max_offset, dy + max_offset, color)
			else:
				img.set_pixel(dx + max_offset, dy + max_offset, Color(0, 0, 0))
	
	var tex := ImageTexture.create_from_image(img)
	return tex


func change_texture():
	if textures.is_empty() or target_meshes.is_empty():
		return
	
	current_texture_index = (current_texture_index + 2) % textures.size()
	var new_texture = textures[current_texture_index]
	
	
	
	for mesh in target_meshes:
		var material = mesh.get_active_material(0)

		if material:
			if material is ShaderMaterial:
				material.set_shader_parameter("tex", new_texture)
			elif material is StandardMaterial3D:
				material.albedo_texture = new_texture

func changePatchScale():
	for mesh in target_meshes:
		var material = mesh.get_active_material(0)
		if material:
			if material is ShaderMaterial:
				if material.get_shader_parameter("PATCH_SCALE") != null:
					print("patch scale de ",patchScale);
					material.set_shader_parameter("PATCH_SCALE", patchScale)
		

func _toggle_mouse_capture() -> void:
	_mouse_captured = not _mouse_captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _mouse_captured else Input.MOUSE_MODE_VISIBLE
