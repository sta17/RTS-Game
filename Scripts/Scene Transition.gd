extends Node3D

@export_file var next_scene_path = ""
@export var spawn_point:String = ""

# use this as base for respawn, potentially + some in the y to stay on the ground rather in it.

func _on_area_3d_body_entered(body):
	pass # Replace with function body.
	if body.has_method("player"):
		var node = get_node(NodePath("/root/Start/SceneManager"))
		node.transition_to_scene(next_scene_path,spawn_point)
