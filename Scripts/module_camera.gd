extends RefCounted

# Hold Camera Operations

static func get_vector3_from_camera_raycast(camera:Camera3D,camera_2D_Coords:Vector2) -> Vector3:
	var ray_from:Vector3 = camera.project_ray_origin(camera_2D_Coords)
	var ray_to:Vector3 = ray_from + camera.project_ray_normal(camera_2D_Coords) * 1000.0
	var ray_parameters:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from,ray_to)
	
	var result:Dictionary = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_parameters)
	if result: return result.position
	else: return Vector3.ZERO

static func get_collider_from_camera_raycast(camera:Camera3D,camera_2D_Coords:Vector2) -> Node3D:
	var ray_from:Vector3 = camera.project_ray_origin(camera_2D_Coords)
	var ray_to:Vector3 = ray_from + camera.project_ray_normal(camera_2D_Coords) * 1000.0
	var ray_parameters:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from,ray_to)
	
	var result:Dictionary = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_parameters)
	if "collider" in result.keys():
		return result["collider"] 
	else: return null
