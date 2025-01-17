extends Node3D

# 26bf3664 - green

# bf262964 - red

@onready var unit_data:Dictionary = {}

@onready var area:Area3D = $Height/Area3D
@onready var area_colshape:CollisionShape3D = $Height/Area3D/CollisionShape3D
@onready var model:MeshInstance3D = $Height/building_preview
@onready var model_roof:MeshInstance3D = $Height/building_preview/Roof

func model_green() -> void:
	model.set("instance_shader_parameters/instance_color_01",Color("26bf3664"))
	model_roof.set("instance_shader_parameters/instance_color_01",Color("26bf3664"))
	
func model_red() -> void:
	model.set("instance_shader_parameters/instance_color_01",Color("bf262964"))
	model_roof.set("instance_shader_parameters/instance_color_01",Color("bf262964"))
	
func enable_area() -> void:area_colshape.disabled = false
func disable_area() -> void:area_colshape.disabled = true

func placement_check() -> bool:
	#model_red() #default
	
	if area.has_overlapping_bodies():
		#print("Area3D is clipping something")
		return false
	
	var area_collision_shape:BoxShape3D = area_colshape.get_shape()
	var area_size:Vector3 = area_collision_shape.size * 0.5
	var points_to_check:Array = [
		area_colshape.global_transform.origin + Vector3(area_size.x,-area_size.y,area_size.z),
		area_colshape.global_transform.origin + Vector3(area_size.x,-area_size.y,-area_size.z),
		area_colshape.global_transform.origin + Vector3(-area_size.x,-area_size.y,-area_size.z),
		area_colshape.global_transform.origin + Vector3(-area_size.x,-area_size.y,area_size.z),
		]
	
	var y_distances:Array = []
	
	var i:int = 0
	for point in points_to_check:
		
		var ray_from:Vector3 = points_to_check[i]
		var ray_to:Vector3 = ray_from + Vector3(0,-20.0,0)
		var ray_param:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from,ray_to)
		ray_param.collision_mask = 0b10
		
		var raycasted_result:Variant = get_world_3d().get_direct_space_state().intersect_ray(ray_param)
		if raycasted_result:
			var y_distance:float = ray_from.y - raycasted_result.position.y
			y_distances.append(y_distance)
		else:
			#print("A raycast failed to hit the ground.")
			return false
		i += 1
	
	for y_distance in y_distances:
		if y_distance > 2.0:
			#print("Not Plannar enough, raycast failed on Y check.")
			return false
	
	#print("Everything is good! Building can be placed")
	#model_green()
	return true
