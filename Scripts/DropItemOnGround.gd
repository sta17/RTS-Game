@icon("res://Assets/Mine/UI.svg")
extends Panel

var input_handler: Object

func _can_drop_data(at_position, data):
	if data is Dictionary:
		if data["SlotData"] == null:
			return false
		if data["Slot"] == null:
			return false
		if data["inv"] == null:
			return false
		if data["Slot"] == self:
			return false
		return true
	return false

func _drop_data(at_position, data):
	var inv: Inv = data["inv"]
	
	var item_packed_scane:PackedScene = load("res://Scenes/Items/CollectibleItem2D.tscn")
	var item_node:CollectibleItem2D = item_packed_scane.instantiate()
	item_node.item = data["SlotData"].Item
	item_node.stackSize = data["SlotData"].amount
	item_node._ready()
	
	# switch out for the item drop node location, given to the UI at start
	input_handler.currentScene.getItemsLocation().add_child(item_node)
	
	item_node.transform.origin = input_handler.display_object.transform.origin
	
	data["inv"].Remove_at_Index(data["Slot"].index)
	data["Slot"].RemoveSlotData()
	data["Slot"].dragging = false
	
	input_handler.item_dragging_release()
