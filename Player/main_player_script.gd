class_name Player 
extends CharacterBody3D

@export_category("Input mapping contexts")
@export var UIInput : GUIDEMappingContext
@export var MovementInput : GUIDEMappingContext
@export var InteractionInput : GUIDEMappingContext
@export var WeaponsInput : GUIDEMappingContext

@export_category("Input Actions")
@export var jumpAction : GUIDEAction

@export_category("Controllers")
@export var weapon_controller : WeaponController
@export var quest_tracker : QuestTracker
@export var inventory : Inventory


@export_category("Camera")
@export var head_tilt_amount : float = 1.5
@export var BASE_FOV := 80.0
@export var FOV_CHANGE := 1.0
@export_range(.001,.03,.001) var look_sensitivity := 0.01


@export_category("Movement")
@export var gravity := 16.0

@export var jumpForce := 5.0

@export_group("Ground")
@export var current_speed := 15.0
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0

@export_group("Air")
@export var air_cap := 0.85
@export var air_accel := 800.0
@export var air_move_speed := 500.0



########################################################
@onready var camera : Camera3D = %PlayerCamera
@onready var stairs_ahead_raycast: RayCast3D = $StairsAheadRayCast
@onready var stairs_below_raycast: RayCast3D = $StairsBelowRayCast


#Saved inputs and directions
var input_dir := Vector2.ZERO
var wish_dir := Vector3.ZERO

#Headbob variables
const headbob_move_amount := 0.06 # side to side
const headbob_frequency := 1.4 # how fast is side to side
var headbob_time := 0.0

#Stair movment variables
const MAX_STEP_HEIGHT := 0.5
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

#Jump buffer && (maybe coyoteTime) variables

var jump_avalible := false
var jump_buffer_running := false
var coyote_timer_running := false

########################################################

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
func _ready():
	Global.player = self
	
	GUIDE.enable_mapping_context(UIInput)
	GUIDE.enable_mapping_context(MovementInput)
	GUIDE.enable_mapping_context(InteractionInput)
	GUIDE.enable_mapping_context(WeaponsInput)

	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	#Input signal connections
	jumpAction.triggered.connect(StartJumpBuffer)

########################################################

#region Camera effets ------ Smoothing ## Tilting ## Bobing
func fov_change(delta):
	var velocity_clamped = clamp(velocity.length(), 0.5, 20)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 5.0)

var _saved_camera_global_pos = null
func _save_camera_pos_for_smoothing():
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = %CameraSmooth.global_position

func _slide_camera_smooth_back_to_origin(delta):
	if _saved_camera_global_pos == null: return
	%CameraSmooth.global_position.y = _saved_camera_global_pos.y
	%CameraSmooth.position.y = clampf(%CameraSmooth.position.y, -0.7,0.7) # Clamp incase teleported
	var move_amount = max(self.velocity.length() * delta, current_speed/2 * delta)
	%CameraSmooth.position.y = move_toward(%CameraSmooth.position.y, 0.0, move_amount)
	_saved_camera_global_pos = %CameraSmooth.global_position
	if %CameraSmooth.position.y == 0:
		_saved_camera_global_pos = null # Stop smoothing camera

func cam_tilt_effect():
	if input_dir.x > 0:
		%Head.rotation.z = lerp_angle(%Head.rotation.z, deg_to_rad(-head_tilt_amount), 0.05)
	elif input_dir.x < 0:
		%Head.rotation.z = lerp_angle(%Head.rotation.z, deg_to_rad(head_tilt_amount), 0.05)
	else:
		%Head.rotation.z = lerp_angle(%Head.rotation.z, deg_to_rad(0), 0.05)
	
func headbob_effect(delta):
	headbob_time += delta * velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * headbob_frequency * 0.5) * headbob_move_amount,
		sin(headbob_time * headbob_frequency) * headbob_move_amount,
		0
	)

#endregion

#region Stairs && Slope checks && Movement

func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	stairs_below_raycast.force_raycast_update()
	var floor_below : bool = stairs_below_raycast.is_colliding() and not is_surface_too_steep(stairs_below_raycast.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() == _last_frame_was_on_floor
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = KinematicCollision3D.new()
		if self.test_move(self.global_transform, Vector3(0,-MAX_STEP_HEIGHT,0), body_test_result):
			_save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false

	if self.velocity.y > 0 or (self.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))

	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y

		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: return false
		stairs_ahead_raycast.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		stairs_ahead_raycast.force_raycast_update()
		if stairs_ahead_raycast.is_colliding() and not is_surface_too_steep(stairs_ahead_raycast.get_collision_normal()):
			_save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false
#endregion

#region Jump Buffer && Coyote Timer

func StartJumpBuffer():
	jump_buffer_running = true
	%JumpBufferTimer.start()

func Jump():
	self.velocity.y = 0 
	self.velocity.y += jumpForce

func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer_running = false
	
func _on_coyote_timer_timeout() -> void:
	coyote_timer_running = false
	
#endregion

############-----Player PHYSICS-----###############

func friction(target_speed, applied_friction, delta:float)->void:
	var control = max(self.velocity.length(), ground_decel)
	var drop = control * applied_friction * delta
	var new_speed = max(self.velocity.length() - drop, target_speed)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed

func _handle_ground_physics(delta: float) -> void:
	var add_speed_till_cap = current_speed - Vector3(self.velocity.x, 0, self.velocity.z).length()
	
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * current_speed
		self.velocity += accel_speed * wish_dir  
	
	friction(0.0, ground_friction, delta)

func _handle_air_physics(delta: float) -> void:
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)

	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta # Usually is adding this one.
		accel_speed = min(accel_speed, add_speed_till_cap) # Works ok without this but sticking to the recipe
		self.velocity += accel_speed * wish_dir


func _handle_jump_physics() -> void:
	if is_on_floor():
		jump_avalible = true
		
		if jump_buffer_running:
			jump_avalible = false
			Jump()
	
	if jumpAction.is_triggered() and coyote_timer_running and jump_avalible:
		jump_avalible = false
		Jump()

####################################################

func _physics_process(delta):
	if is_on_floor(): 
		_last_frame_was_on_floor = Engine.get_physics_frames()
	
	if jump_avalible and !is_on_floor() and not coyote_timer_running:
		coyote_timer_running = true
		%CoyoteTimer.start()
	
	cam_tilt_effect()
	
	update_gravity(delta)
	update_input(delta)
	update_velocity(delta)


#Callables for the movement states
func update_gravity(delta):
	self.velocity.y -= gravity * delta 


func update_input(delta):
	input_dir = Input.get_vector("left", "right", "forward", "back").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	if is_on_floor() or _snapped_to_stairs_last_frame:
		_handle_ground_physics(delta)
		
	else:
		_handle_air_physics(delta)
		
	_handle_jump_physics()


func update_velocity(delta):
	if not _snap_up_stairs_check(delta):
		move_and_slide()
		_snap_down_to_stairs_check()
	 
	_slide_camera_smooth_back_to_origin(delta)
