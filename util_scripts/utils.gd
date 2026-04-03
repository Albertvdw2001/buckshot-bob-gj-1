class_name Node2dUtils

# relative_mouse_pos is my own made up value for the local_mouse_pos in a global space without taking
# rotation of self into account.
# In simple terms: the x and y of global_mouse_pos relative to the node's global position
# Useful in avoiding x of local_mouse_pos always being a positive value when applying look_at on
# global_mouse_pos each frame
static func get_relative_global_mouse_pos(node: Node2D) -> Vector2:
	var global_mouse_pos = node.get_global_mouse_position()
	var global_body_pos = node.global_position
	var x = global_mouse_pos.x - global_body_pos.x
	var y = global_mouse_pos.y - global_body_pos.y
	return Vector2(x, y)
