@icon("res://Assets/Inventory Addin/node_inventory_system_base.svg")
extends Resource
class_name InvSlot

@export var Item: InventoryItem
@export var amount: int
@export var index: int
@export var max_stack := -1

func get_item_id() -> int:
	if Item == null:
		return InventoryItem.NONE
	else:
		return Item.id

func add(item : InventoryItem, amount : int) -> int:
	if item == null:
		return amount
	if amount <= 0 or (self.item != item and self.item != null):
		return amount
	var max_stack = get_max_stack_for_item(item)
	var amount_to_add = min(amount, max_stack - self.amount)
	self.amount = self.amount + amount_to_add;
	if amount_to_add > 0 and self.item == null:
		self.item = item
	return amount - amount_to_add

func remove(item : InventoryItem, amount : int) -> int:
	if item == null:
		return amount
	if amount <= 0 or (self.item != item && self.item != null):
		return amount;
	var amount_to_remove = min(amount, self.amount);
	self.amount = self.amount - amount_to_remove;
	if self.amount <= 0:
		self.item = null;
	return amount - amount_to_remove

func get_max_stack_for_item(item : InventoryItem) -> int:
	if max_stack == -1:
		return item.max_stack
	else:
		return max_stack

func get_max_stack() -> int:
	return get_max_stack_for_item(Item)

func is_full() -> bool:
	if Item == null:
		return false
	if amount < get_max_stack():
		return false
	return true
